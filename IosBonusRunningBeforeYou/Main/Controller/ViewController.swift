//
//  ViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var startButtonField: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
      
        startButtonField.clipsToBounds = true
        
        startButtonField.layer.cornerRadius = 5
    }
    
//     Unwind Segue
    @IBAction func unwindTOList(_ segue: UIStoryboardSegue){

    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if segue.identifier == "groupRunningStart"{
//
//        }
//    }
}
