//
//  ViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var groupId:Int?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Unwind Segue
    @IBAction func unwindTOList(_ segue: UIStoryboardSegue){

        guard let groupDetailVC = segue.source as? GroupDeatilViewController  else{
            return
        }
        guard let  groupId = groupDetailVC.groupDetail.groupId else {
            return
        }
        print("unwindTOList groupId = \(groupId)")

    }
}
