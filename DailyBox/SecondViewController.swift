//
//  SecondViewController.swift
//  DailyBox
//
//  Created by Clvv on 16/2/25.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController ,UITableViewDelegate,UITableViewDataSource{
    //定义区
    var Agendas : [AgendaClass] = []
    @IBOutlet weak var tableView1: UITableView!
    var db : COpaquePointer = nil
    var stmt : COpaquePointer = nil
    //Documents 目录
    lazy var documentsPath : String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first!
    }()
    var Agenda1 = AgendaClass() //某条Agenda
    
    
    //界面加载
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView1.delegate = self
        tableView1.dataSource = self
        createOrOpenDatabase()
        createTable()
        loadAgenda()
        tableView1.tableFooterView = UIView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return Agendas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        //定义cell的样式
        let cellId = "agenda"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell!
        
        //添加内容
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy,MM,dd,hh,mm"
        let dateArr = Agendas[indexPath.row].date.componentsSeparatedByCharactersInSet(NSCharacterSet(charactersInString: ","))
        let month = dateArr[1]
        let day = dateArr[2]
        let hour = dateArr[3]
        let minute = dateArr[4]
        (cell.viewWithTag(1) as! UILabel).text = month+"月"+day+"日"
        (cell.viewWithTag(2) as! UILabel).text = hour+":"+minute
        (cell.viewWithTag(3) as! UILabel).text = Agendas[indexPath.row].issue
        (cell.viewWithTag(4) as! UILabel).text = Agendas[indexPath.row].address
        
        (cell.viewWithTag(1) as! UILabel).adjustsFontSizeToFitWidth = true
        (cell.viewWithTag(2) as! UILabel).adjustsFontSizeToFitWidth = true
        (cell.viewWithTag(3) as! UILabel).adjustsFontSizeToFitWidth = true
        (cell.viewWithTag(4) as! UILabel).adjustsFontSizeToFitWidth = true
        return cell
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
        let string : NSString = "delete from Agenda where date = '\(date)' AND address = '\(address)' AND issue = '\(issue)'"
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
    
    //取出数据
    func loadAgenda(){
        //准备sql语句
        let string :NSString = "select date, address, issue from Agenda"
        let sql = string.UTF8String
        
        //解析sql语句
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("agenda load failed111")
            sqlite3_close(db)
        }
        //执行sql
        var i = 0
        Agendas = []
        while sqlite3_step(stmt) == SQLITE_ROW{
            Agendas += [AgendaClass()]
            let cdate = sqlite3_column_text(stmt,0)
            Agendas[i].date = String(UTF8String: UnsafePointer(cdate))!
            let caddress = sqlite3_column_text(stmt,1)
            Agendas[i].address = String(UTF8String: UnsafePointer(caddress))!
            let cissue = sqlite3_column_text(stmt,2)
            Agendas[i].issue = String(UTF8String: UnsafePointer(cissue))!
            i++
        }
        
    }
    //转入日程详情
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier ==  "3"){
            (segue.destinationViewController as! AgendaTableViewController).mode = 0
            let Agenda2 = (segue.destinationViewController as! AgendaTableViewController).Agenda
            let date = NSDate()
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy,MM,dd,hh,mm"
            let strDate = dateFormatter.stringFromDate(date)
            Agenda2.date = strDate
            Agenda2.address = ""
            Agenda2.issue = ""
            
        }else if (segue.identifier ==  "4"){
            (segue.destinationViewController as! AgendaTableViewController).mode = 1
            let Agenda2 = (segue.destinationViewController as! AgendaTableViewController).Agenda
            Agenda2.date = Agenda1.date
            Agenda2.issue = Agenda1.issue
            Agenda2.address = Agenda1.address
            
        }
    }
    //点击了某条笔记
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        Agenda1.date  = Agendas[Agendas.count-indexPath.row-1].date
        Agenda1.issue = Agendas[Agendas.count-indexPath.row-1].issue
        Agenda1.address = Agendas[Agendas.count-indexPath.row-1].address
        return indexPath
    }
    //刷新
    func refresh(){
        viewDidLoad()
        tableView1.reloadData()
    }
    
    @IBAction func unWind(segue: UIStoryboardSegue) {
        NSTimer.scheduledTimerWithTimeInterval(0.001, target: self, selector: "refresh", userInfo: nil, repeats: false)
        
        
    }

    //设置编辑状态 删除
    @IBOutlet weak var EditButten1: UIBarButtonItem!
    @IBAction func EditButtonClick(sender: UIBarButtonItem) {
        tableView1.setEditing(!tableView1.editing, animated: true)
        if tableView1.editing == true {
            sender.image = UIImage(named: "close")
        }else{
            sender.image = UIImage(named: "edit")
        }
    }
    
    
    //可编辑状态
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    
    func tableView(tableView: UITableView, titleForDeleteConfirmationButtonForRowAtIndexPath indexPath: NSIndexPath) -> String? {
        return "删除"
    }
    
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        
        return UITableViewCellEditingStyle.Delete
    }
    
    //确认删除
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        deleteAgenda(Agendas[Agendas.count-indexPath.row-1].date, address: Agendas[Agendas.count-indexPath.row-1].address, issue: Agendas[Agendas.count-indexPath.row-1].issue)
        Agendas.removeAtIndex(Agendas.count - indexPath.row-1)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }

}