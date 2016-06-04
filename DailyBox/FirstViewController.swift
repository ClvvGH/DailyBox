//
//  FirstViewController.swift
//  DailyBox
//
//  Created by Clvv on 16/2/25.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController,UITableViewDataSource,UITableViewDelegate {
    
    @IBOutlet weak var TabBarButton1: UITabBarItem!
    
    //Documents 目录
    lazy var documentsPath : String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first!
    }()
    
    
    var notes : [NoteClass] = []


    @IBOutlet weak var tableView1: UITableView!
    
    
    
    // 加载界面
    override func viewDidLoad() {
        super.viewDidLoad()
        createOrOpenDatabase()
        createTable()
        loadNote()
        tabBarController?.tabBar.tintColor = UIColor.redColor()
        tabBarController?.tabBar.alpha = 0.6
        tableView1.dataSource = self
        tableView1.delegate = self
        tableView1.tableFooterView = UIView()
    }
    
    //创建或打开数据库
    var db : COpaquePointer = nil
    var stmt : COpaquePointer = nil
    func createOrOpenDatabase(){
        let path : NSString = "\(documentsPath)/Note.sqlite3"
        let fileName = path.UTF8String
        if sqlite3_open(fileName, &db) != SQLITE_OK
        {
            print("create or open failed")
            sqlite3_close(db)
        }
    }
    
    //创建数据表
    func createTable(){
        let string : NSString = "create table if not exists Note(id integer primary key autoincrement, title text, time text, body text)"
        let sql = string.UTF8String
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK{
            print ("create table failed")
            sqlite3_close(db)
        }
    }
    
    
    //插入Note数据
    func insertNote(title: String,time: String, body: String){
        //准备sql 语句
        let string :NSString = "insert into Note(title, time, body) values(?, ?, ?)"
        let sql = string.UTF8String
        
        //解析sql语句
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("note insert failed")
            sqlite3_close(db)
        }
        //绑定参数
        let ctitle = (title as NSString).UTF8String
        let ctime = (time as NSString).UTF8String
        let cbody = (body as NSString).UTF8String
        sqlite3_bind_text(stmt,1,ctitle,-1,nil)
        sqlite3_bind_text(stmt,2,ctime,-1,nil)
        sqlite3_bind_text(stmt,3,cbody,-1,nil)
        
        //执行sql语句
        if sqlite3_step(stmt) == SQLITE_ERROR{
            sqlite3_close(db)
            print ("note insert failed")
        }else{
            sqlite3_finalize(stmt)
        }
    }
    
    
    
       //删除数据
    func deleteNote(time: String,title:String,body:String){
        //准备sql语句
        let string : NSString = "delete from Note where time = '\(time)'AND title = '\(title)' AND body = '\(body)'"
        let sql = string.UTF8String
        //解析sql
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("note load failed 001789")
            sqlite3_close(db)
        }
        
        //执行
        if sqlite3_exec(db,sql,nil,nil,nil) == SQLITE_ERROR{
            print ("002")
        }
    }
    
    //取出数据
    func loadNote(){
        //准备sql语句
        let string :NSString = "select title, time, body from Note"
        let sql = string.UTF8String
        
        //解析sql语句
        if sqlite3_prepare_v2(db, sql, -1, &stmt, nil) != SQLITE_OK{
            print ("note load failed")
            sqlite3_close(db)
        }
        //执行sql
        var i = 0
        notes = []
        while sqlite3_step(stmt) == SQLITE_ROW{
            notes += [NoteClass()]
            let ctitle = sqlite3_column_text(stmt,0)
            notes[i].title = String(UTF8String: UnsafePointer(ctitle))
            let ctime = sqlite3_column_text(stmt,1)
            notes[i].time = String(UTF8String: UnsafePointer(ctime))
            let cbody = sqlite3_column_text(stmt,2)
            notes[i].body = String(UTF8String: UnsafePointer(cbody))
            i++
        }

    }
    
    
    //  cell样式
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        //定义cell的样式
        let cellId = "cellId"
        let cell = tableView.dequeueReusableCellWithIdentifier(cellId) as UITableViewCell!
        
        //添加内容
        cell.textLabel!.text = notes[notes.count-indexPath.row-1].title
        cell.detailTextLabel!.text = notes[notes.count-indexPath.row-1].time
        return cell
    }
    // 每个Section的行数
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return notes.count
    }

    
    
    //转入笔记详情
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if (segue.identifier ==  "1"){
            (segue.destinationViewController as! NoteViewController).screenTitle = "新建笔记"
            (segue.destinationViewController as! NoteViewController).buttonTitle = "创建"
            (segue.destinationViewController as! NoteViewController).mode = 0
            let note2 = (segue.destinationViewController as! NoteViewController).note
            note2.title = ""
            note2.body = ""
        }else if (segue.identifier == "0"){
            (segue.destinationViewController as! NoteViewController).screenTitle = "编辑笔记"
            (segue.destinationViewController as! NoteViewController).buttonTitle = "保存"
            (segue.destinationViewController as! NoteViewController).mode = 1
            let note2 = (segue.destinationViewController as! NoteViewController).note
            note2.title = note1.title
            note2.body = note1.body
            note2.time = note1.time
        }
    }
    //点击了某条笔记
    var note1 = NoteClass()
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        note1.title = notes[notes.count-indexPath.row-1].title
        note1.time = notes[notes.count-indexPath.row-1].time
        note1.body = notes[notes.count-indexPath.row-1].body
        return indexPath
    }

    
    //刷新
    func refresh(){
        viewDidLoad()  
        tableView1.reloadData()
    }
    

    @IBAction func unWindToFirst(segue: UIStoryboardSegue) {
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
        deleteNote(notes[notes.count-indexPath.row-1].time, title: notes[notes.count-indexPath.row-1].title, body: notes[notes.count-indexPath.row-1].body)
        notes.removeAtIndex(notes.count - indexPath.row-1)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Fade)
    }
}

