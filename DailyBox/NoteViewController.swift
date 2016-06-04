//
//  NoteViewController.swift
//  DailyBox
//
//  Created by Clvv on 16/2/26.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class NoteViewController: UIViewController,UITextViewDelegate{

    @IBOutlet weak var noteTitle: UILabel!
    @IBOutlet weak var titleText1: UITextField!
    @IBOutlet weak var bodyText1: UITextView!
    @IBOutlet weak var buttonTitle2: UIButton!
    var screenTitle = String()
    var buttonTitle = String()
    var note = NoteClass()
    var mode = 0  // 0 是创建 1 是修改
    
    //Documents 目录
    lazy var documentsPath : String = {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        return paths.first!
    }()
    var db : COpaquePointer = nil
    var stmt : COpaquePointer = nil
    
    //保存 或 修改
    @IBAction func saveButtonClick(sender: UIButton) {
        //创建存档目录
        //取得系统时间
        let date = NSDate()
        let timeFormatter = NSDateFormatter()
        timeFormatter.dateFormat = "yyyy-MM-dd at HH:mm:ss"
        let StrTime = timeFormatter.stringFromDate(date) as String
        //判断标题是否为空
        if titleText1.text! == ""{
            titleText1.text! = "未命名"
        }
        //执行
        if mode == 0 {
            insertNote(titleText1.text!, time: StrTime, body: bodyText1.text)
        }else{
            deleteNote(note.time, title: note.title, body: note.body)
            insertNote(titleText1.text!, time: StrTime, body: bodyText1.text)
        }
    }
    // 键盘出现 防止键盘遮挡
    @IBOutlet weak var textViewBottom: NSLayoutConstraint!
    func textViewDidBeginEditing(textView: UITextView) {
        textViewBottom.constant = 216
    }
    func textViewDidEndEditing(textView: UITextView) {
        textViewBottom.constant = 0
    }
    
    //界面加载
    override func viewDidLoad() {
        super.viewDidLoad()
    
        createOrOpenDatabase()
        createTable()
        
        buttonTitle2.setTitle(buttonTitle, forState: UIControlState.Application)
        noteTitle.text = screenTitle
        titleText1.text = note.title
        bodyText1.text = note.body
        bodyText1.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
        
    

    //插入 保存Note数据
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
    //创建数据表
    func createTable(){
        let string : NSString = "create table if not exists Note(id integer primary key autoincrement, title text, time text, body text)"
        let sql = string.UTF8String
        if sqlite3_exec(db, sql, nil, nil, nil) != SQLITE_OK{
            print ("create table failed 000")
            sqlite3_close(db)
        }
    }
    //创建或打开数据库
    func createOrOpenDatabase(){
        let path : NSString = "\(documentsPath)/Note.sqlite3"
        let fileName = path.UTF8String
        if sqlite3_open(fileName, &db) != SQLITE_OK
        {
            print("create or open failed")
            sqlite3_close(db)
        }
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
