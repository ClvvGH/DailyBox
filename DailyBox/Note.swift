//
//  Note.swift
//  DailyBox
//
//  Created by Clvv on 16/2/26.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class NoteClass : NSObject {
    //题目、时间、文章 
    var title :String! = "未命名"
    var time  : String! = "2016-01-01 at 00:00:00"
    var body :String! = ""
    // init
    override init(){}
    init(title: String,time: String,body: String){
        self.title = title
        self.time = time
        self.body = body
    }
    
    
}

