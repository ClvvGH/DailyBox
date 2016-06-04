//
//  AgendaTableViewController.swift
//  DailyBox
//
//  Created by Clvv on 16/3/22.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class AgendaTableViewController: UITableViewController {
    //定义区
    var Agenda = AgendaClass()
    var db : COpaquePointer = nil
    var stmt : COpaquePointer = nil
    lazy var documentsPath : String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first!
    }()
    @IBOutlet weak var datePicker1: UIDatePicker!
    @IBOutlet weak var addressTextField1: UITextField!
    @IBOutlet weak var issueTextField1: UITextField!
    var mode = 0  // 0 是创建 1 是修改
    
    
    
    //界面加载
    override func viewDidLoad() {
        super.viewDidLoad()
        createOrOpenDatabase()
        createTable()
        issueTextField1.text = Agenda.issue
        addressTextField1.text = Agenda.address
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy,MM,dd,hh,mm"
        datePicker1.date = dateFormatter.dateFromString(Agenda.date)!
        datePicker1.minimumDate = NSDate()
    }
    
    @IBAction func approveButtonClick1(sender: UIButton) {
        
        Agenda.address = addressTextField1.text!
        Agenda.issue = issueTextField1.text!
        let date1 = datePicker1.date
        let date2 = NSDate()
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let strDate = dateFormatter.stringFromDate(date1)
        Agenda.date = strDate
        let nowDate = dateFormatter.stringFromDate(date2)
        let dateArr1 = strDate.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        let dateArr2 = nowDate.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        if mode == 0 {
            insertAgenda(Agenda.date, address: Agenda.address, issue: Agenda.issue)
            
        }
        else{
            deleteAgenda(Agenda.date, address: Agenda.address, issue: Agenda.issue)
            insertAgenda(Agenda.date, address: Agenda.address, issue: Agenda.issue)
        }
        //添加本地推送 1小时前提醒
        let pushtime = timeJugde(dateArr1) - 60 * 60
        let nowtime = timeJugde(dateArr2)
        if (pushtime - nowtime) > 0{
            let timeInterval = pushtime - nowtime
            let fireDate = NSDate(timeIntervalSinceNow: Double(timeInterval))
            let notification = UILocalNotification()
            notification.fireDate = fireDate
            notification.timeZone = NSTimeZone.defaultTimeZone()
            notification.soundName = UILocalNotificationDefaultSoundName
            notification.alertBody = dateArr1[3] + ":" + dateArr1[4] + Agenda.issue + "(" + Agenda.address + ")"
            notification.alertAction = "收到"
            var userInfo:[NSObject : AnyObject] = [NSObject : AnyObject]()
            userInfo["issue"] = Agenda.issue
            userInfo["time"] = dateArr1[3] + ":" + dateArr1[4]
            userInfo["address"] = Agenda.address
            notification.userInfo = userInfo
            notification.applicationIconBadgeNumber = 1
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        }
    }
    //将时间转换成秒
    func timeJugde ( dateArr : [String]) -> Int{
        var second :Int = 0
        let year = (dateArr[0] as NSString).integerValue
        for index in 2016..<year {
            if isLeapYear(index){
                second += 366 * 24 * 60 * 60
            }else {
                second += 365 * 24 * 60 * 60
            }
        }
        
        let month = (dateArr[1] as NSString).integerValue
        for index in 1..<month{
            switch (month){
            case 1,3,5,7,8,10,12:
                second += (index) * 31 * 24 * 60 * 60
            case 4,6,9,11:
                second += (index) * 30 * 24 * 60 * 60
            case 2:
                if isLeapYear(year){
                    second += 29 * 24 * 60 * 60
                }else{
                    second += 28 * 24 * 60 * 60
                }
            default:
                print("error switch")
            }
        }
        let day = (dateArr[2] as NSString).integerValue
        second += (day-1) * 24 * 60 * 60
        let hour = (dateArr[3] as NSString).integerValue
        second += (hour-1) * 60 * 60
        let minute = (dateArr[4] as NSString).integerValue
        second += (minute-1) * 60
        
        return second
    }
    func isLeapYear (year: Int)->Bool{
        if (year % 4 == 0 && year % 100 != 0 || year % 400 == 0){
            return true
        }else {
            return false
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1{
            return 2
        }else{
            return 1
        }

    }
    
    //创建或打开数据库
    func createOrOpenDatabase(){
        let path : NSString = "\(documentsPath)/Agenda.sqlite3"
        let fileName = path.UTF8String
        if sqlite3_open(fileName, &db) != SQLITE_OK
        {
            print("create or open failed")
            sqlite3_close(db)
        }else{
            print("create agendasql OK")
        }
    }
    
    //创建数据表
    func createTable(){
        let string : NSString = "create table if not exists Agenda(id integer primary key autoincrement, date text, address text, issue text)"
        let sql = string.UTF8String
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK{
            print ("create table failed")
            sqlite3_close(db)
        }else{
            print("create table OK")
        }
    }
    
    
    //插入Agenda数据
    func insertAgenda(date : String, address:String, issue: String){
        //准备sql 语句
        let string :NSString = "insert into Agenda(date, address, issue) values(?, ?, ?)"
        let sql = string.UTF8String
        
        //解析sql语句
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("agenda insert failed")
            sqlite3_close(db)
        }
        //绑定参数
        let cdate = (date as NSString).UTF8String
        let caddress = (address as NSString).UTF8String
        let cissue = (issue as NSString).UTF8String
        sqlite3_bind_text(stmt,1,cdate,-1,nil)
        sqlite3_bind_text(stmt,2,caddress,-1,nil)
        sqlite3_bind_text(stmt,3,cissue,-1,nil)
        //执行sql语句
        if sqlite3_step(stmt) == SQLITE_ERROR{
            sqlite3_close(db)
            print ("note insert failed")
        }else{
            sqlite3_finalize(stmt)
        }
    }
    
    
    
    //删除数据
    func deleteAgenda(date : String, address:String, issue: String){
        //准备sql语句
        let string : NSString = "delete from Note where date = '\(date)' AND address = '\(address)' AND issue = '\(issue)'"
        let sql = string.UTF8String
        //解析sql
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("note load failed 001789")
            sqlite3_close(db)
        }
        
        //执行
        if sqlite3_exec(db,sql,nil,nil,nil) == SQLITE_ERROR{
            print ("deletesql error")
        }
    }
    
    
    }

