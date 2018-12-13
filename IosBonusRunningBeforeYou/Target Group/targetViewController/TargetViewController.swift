//
//  TargetViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/12/13.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class TargetViewController: UIViewController {
    
    @IBOutlet weak var userDaykm: UILabel!
    @IBOutlet weak var targetDaykm: UILabel!
    @IBOutlet weak var userMonthkm: UILabel!
    @IBOutlet weak var targetMonthkm: UILabel!
    
    @IBOutlet weak var targetD1line: UIImageView!
    @IBOutlet weak var targetD1circle: UIImageView!
    @IBOutlet weak var targetD2line: UIImageView!
    @IBOutlet weak var targetD2circle: UIImageView!
    @IBOutlet weak var targetD3line: UIImageView!
    @IBOutlet weak var targetD3circle: UIImageView!
    @IBOutlet weak var targetDbtn: UIButton!
    
    
    @IBOutlet weak var targetM1line: UIImageView!
    @IBOutlet weak var targetM1circle: UIImageView!
    @IBOutlet weak var targetM2line: UIImageView!
    @IBOutlet weak var targetM2circle: UIImageView!
    @IBOutlet weak var targetM3line: UIImageView!
    @IBOutlet weak var targetM3circle: UIImageView!
    @IBOutlet weak var targetMbtn: UIButton!
    
    
    let communicator = Communicator.shared
    let useremail = "444"
    
    var userItem = [UserItem]()
    var daykm: String = ""
    var monthkm: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserKm(email: useremail)
    }
    
    func getUserKm (email: String) {
        communicator.getUserKm(email: email) { (result, error) in
            if let error = error {
                print("Get UserKm error:\(error)")
                return
            }
            guard let result = result else {
                print("Data is nil")
                return
            }
            print("Get UserKm OK.")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(UserItem.self, from: jsonDate) else {
                print("Fail to decode jsonData.")
                return
            }
            
            self.daykm = String(format: "%.2f", Float(resultObject.target_daily)/1000)
            self.monthkm = String(format: "%.2f", Float(resultObject.target_monthly)/1000)
            
            self.userDaykm.text = self.daykm
            self.userMonthkm.text = self.monthkm
            self.setTargetKm()
            self.setTargetImage()
        }
    }
    
    func setTargetKm() {
        if Float(daykm)! >= Float(1) { // 每日目標
            targetDaykm.text = "3"
        }
        
        if Float(daykm)! >= Float(3) {
            targetDaykm.text = "5"
        }
        
        if Float(monthkm)! >= Float(50) { // 每月目標
            targetMonthkm.text = "75"
        }
        if Float(monthkm)! >= Float(75) {
            targetMonthkm.text = "100"
        }

    }
    
    func setTargetImage() {
        
        if Float(daykm)! >= Float(1) { // 每日目標
            targetD1line.isHidden = false
            targetD1circle.isHidden = false
            targetDbtn.isEnabled = true
        }
        
        if Float(daykm)! >= Float(3) {
            targetD2line.isHidden = false
            targetD2circle.isHidden = false
            targetDbtn.isEnabled = true
        }
        
        if Float(daykm)! >= Float(5) {
            targetD3line.isHidden = false
            targetD3circle.isHidden = false
            targetDbtn.isEnabled = true
        }
        
        if Float(monthkm)! >= Float(50) { // 每月目標
            targetM1line.isHidden = false
            targetM1circle.isHidden = false
            targetMbtn.isEnabled = true
        }
        if Float(monthkm)! >= Float(75) {
            targetM2line.isHidden = false
            targetM2circle.isHidden = false
            targetMbtn.isEnabled = true
        }
        if Float(monthkm)! >= Float(100) {
            targetM3line.isHidden = false
            targetM3circle.isHidden = false
            targetMbtn.isEnabled = true
        }
        
    }
    
}

extension Communicator {
    func getUserKm (email: String, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY : "findByEmail",
                                       EMAIL_KEY : email]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion: completion)
    }
}
