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
    let userDefault = UserDefaults.standard
    var useremail = ""
    let now:Date = Date()
    
    var userItem = [UserItem]()
    var daykm: String = ""
    var monthkm: String = ""
    var pointRecords = PointsRecord()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // userDefault
        useremail = userDefault.string(forKey: "email")!
        
        self.title = "目標"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getUserKm(email: useremail)
    }
    
    @IBAction func targetDbtn(_ sender: UIButton) {
        
        if targetD1circle.isHidden == false {
            self.view.showToast(text: "點數領取成功D")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每日目標1公里"
            self.pointRecords.record_points = 10
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        if targetD2circle.isHidden == false {
            self.view.showToast(text: "點數領取成功D2")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每日目標3公里"
            self.pointRecords.record_points = 20
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        if targetD3circle.isHidden == false {
            self.view.showToast(text: "點數領取成功D3")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每日目標5公里"
            self.pointRecords.record_points = 40
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        targetDbtn.isEnabled = false // 關閉點擊
        targetDbtn.alpha = 0.4 // 設定Button透明度
        
    }
    
    @IBAction func targetMbtn(_ sender: UIButton) {
        
        if targetM1circle.isHidden == false {
            self.view.showToast(text: "點數領取成功M")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每月目標50公里"
            self.pointRecords.record_points = 50
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        if targetM2circle.isHidden == false {
            self.view.showToast(text: "點數領取成功M2")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每月目標75公里"
            self.pointRecords.record_points = 60
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        if targetM3circle.isHidden == false {
            self.view.showToast(text: "點數領取成功M3")
            self.pointRecords.email = useremail
            self.pointRecords.record_name = "完成每月目標100公里"
            self.pointRecords.record_points = 80
            // 時間戳
            let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
            let date = Date(timeIntervalSince1970: timeInterval)
            let dformatter = DateFormatter ()
            dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            self.pointRecords.record_date = dformatter.string(from: date)
            
            let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
            let pointRecordString = String(data: pointRecordData, encoding: .utf8)
            communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                print("inserPoint = \(String(describing: result))")
            }
        }
        
        targetMbtn.isEnabled = false // 關閉點擊
        targetMbtn.alpha = 0.4 // 設定Button透明度
        
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
            targetDbtn.alpha = 1.0
        }
        
        if Float(daykm)! >= Float(3) {
            targetD2line.isHidden = false
            targetD2circle.isHidden = false
            targetDbtn.isEnabled = true
            targetDbtn.alpha = 1.0
        }
        
        if Float(daykm)! >= Float(5) {
            targetD3line.isHidden = false
            targetD3circle.isHidden = false
            targetDbtn.isEnabled = true
            targetDbtn.alpha = 1.0
        }
        
        if Float(monthkm)! >= Float(50) { // 每月目標
            targetM1line.isHidden = false
            targetM1circle.isHidden = false
            targetMbtn.isEnabled = true
            targetMbtn.alpha = 1.0
        }
        
        if Float(monthkm)! >= Float(75) {
            targetM2line.isHidden = false
            targetM2circle.isHidden = false
            targetMbtn.isEnabled = true
            targetMbtn.alpha = 1.0
        }
        
        if Float(monthkm)! >= Float(100) {
            targetM3line.isHidden = false
            targetM3circle.isHidden = false
            targetMbtn.isEnabled = true
            targetMbtn.alpha = 1.0
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

extension UIView{
    
    func showtargetToast(text: String){
        
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 60 - 30, width: expectedSize.width + 20, height: expectedSize.height + 20)
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1, delay: 1, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hidetargetToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}
