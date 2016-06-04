//
//  AgendaViewController.swift
//  DailyBox
//
//  Created by Clvv on 16/3/22.
//  Copyright © 2016年 Clvv. All rights reserved.
//

import UIKit

class AgendaViewController: UIViewController,UITableViewDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    @IBAction func backButtonClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
