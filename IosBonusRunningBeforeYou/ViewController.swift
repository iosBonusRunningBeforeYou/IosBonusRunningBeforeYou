//
//  ViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    // Unwind Segue
    @IBAction func unwindTOList(_ segue: UIStoryboardSegue){
        guard segue.identifier == "save" else {
        return
        }
        
        self.performSegue(withIdentifier: "unwind", sender: self)
        
    }
}
