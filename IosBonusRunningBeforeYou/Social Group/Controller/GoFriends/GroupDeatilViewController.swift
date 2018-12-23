//
//  GroupDeatilViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

import UIKit
import MapKit
import UserNotifications

class GroupDeatilViewController: UIViewController,CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet weak var joinPeopleBtn: UIButton!
    @IBOutlet weak var joinBtn: UIButton!
    @IBOutlet weak var detailMapView: MKMapView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var introduceLabel: UILabel!
    @IBOutlet weak var goRunningBtn: UIButton!
    var segue:String?
    var groupDetail = GoFriendItem()
    var groupInfos = [GoFriendItem]()
    var groupInfo = GoFriendItem()
    let locationManager = CLLocationManager()
    let communicator = Communicator.shared
    var joinNum = 0
    let tag = "GroupDeatilViewController"
    var identifier = "groupRunningStart"
    var email = "Lisa@gmail.com"
    let userDefault = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        guard CLLocationManager.locationServicesEnabled() else {
            return
        }
        // Ask permission
        locationManager.requestAlwaysAuthorization()
        // Prepare locationManager.
        locationManager.delegate = self // important !!!
        // 精準度的設定
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        // 導航類型 .fitness 走路跑步 可以優化系統
        locationManager.activityType = .fitness
        locationManager.startUpdatingLocation()
        detailMapView.delegate = self
        email = userDefault.string(forKey: "email")!
        if segue == "joinSegue"{
            handelViewForJoinSegue()
        }else if segue == "nonJoinSegue"{
            handelViewForNonJoinSegue()
        }
        navigationItem.title = groupDetail.groupName
     
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
         getJoinInfo()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        groupInfos.removeAll()
    }
    
    func getJoinInfo(){
        guard let groupId = groupDetail.groupId else{
            return
        }
        communicator.getJoinInfo(groupId: groupId) { (result, error) in
            if let error = error {
                print("getJoinInfo error:\(error)")
                return
            }
            guard let result = result  else {
                print("getJoinInfo result is nil")
                return
            }
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([GoFriendItem].self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }
            for info in resultObject {
                self.groupInfos.append(info)
            }
            self.joinNum = resultObject.count
            PrintHelper.println(tag: self.tag, line: 90, "joinNum = \(self.joinNum), groupInfo = \(self.groupInfos)")
            NotificationCenter.default.post(name: Notification.Name(rawValue: "getJoinInfo"), object: 0)
        }
    }
    
    
    @IBAction func joinGroupAction(_ sender: UIButton) {
        print("joinGroupAction = \(groupDetail.groupName), \(groupDetail.groupRunningTime)")
        timeNotice(groupName: groupDetail.groupName, groupRunningTime: groupDetail.groupRunningTime)
        groupInfos.removeAll()
        guard let groupId = groupDetail.groupId else{
            return
        }
        communicator.insertGroupJoinState(email: self.email, groupId: groupId) { (result, error) in
            if let error = error {
                print("insertGroupJoinState error:\(error)")
                return
            }
            guard let result = result ,let resultInt = result as? Int else{
                print("get joinStatus nil")
                return
            }
            if resultInt == 1 {
                self.joinBtn.isHidden = true
                self.joinPeopleBtn.isHidden = false
                self.goRunningBtn.isEnabled = true
                 self.getJoinInfo()
            }else {
                print("insertGroupJoinState fail")
            }
        }
    }
    
    @IBAction func goAction(_ sender: UIButton) {
        let alert = UIAlertController(title: "開始揪團跑" , message: "請在開始時間五分鐘內按下確認開始跑步", preferredStyle: .alert)

        let ok = UIAlertAction(title: "確定", style: .default){(action) in
            self.performSegue(withIdentifier: "groupRunningStart", sender: self)
        }
        let cancel = UIAlertAction(title: "取消", style: .destructive){(action) in
        }
        let curDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        dateFormatter.locale = Locale(identifier: "zh_Hant_TW")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        guard let dateStrint = groupDetail.groupRunningTime,
            let date = dateFormatter.date(from: dateStrint) else{
                PrintHelper.println(tag: tag, line: 120, "dateStrint is nil")
                return
        }

        let comparisonResult = comparisonDate(currentDate: curDate, date: date)
        if comparisonResult == ">"{
            alert.addAction(ok)
        }
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func handelViewForJoinSegue(){
        joinBtn.isHidden = true
        joinPeopleBtn.isHidden = false
        timeLabel.text = groupDetail.groupRunningTime
        introduceLabel.text = groupDetail.groupRunningIntroduce
        print("groupDeatil = \(String(describing: groupDetail.groupName))")
        setRouteAnnotations(startLat: groupDetail.startPointLatitude, startLon: groupDetail.startPointLongitude, endLat: groupDetail.endPointLatitude, endLon: groupDetail.endPointLongitude, mapView: detailMapView)
        helperDraw()
    }
    
    @IBAction func returnCurLocation(_ sender: UIButton) {
        self.moveAndZoomMap(self.locationManager, self.detailMapView,0.01,0.01)
    }
    
    @objc
    func closeJoinBtn(notification: Notification){
        
        if joinNum >= 6 {
            joinBtn.isEnabled = false
            showAlert(title: "動作太慢囉～", message: "揪團跑最多六人！")
        }
    }
    
    func handelViewForNonJoinSegue(){
           NotificationCenter.default.addObserver(self, selector: #selector(closeJoinBtn(notification:)), name: Notification.Name(rawValue: "getJoinInfo"), object: nil)
        joinBtn.isHidden = false
        joinPeopleBtn.isHidden = true
        goRunningBtn.isEnabled = false
        timeLabel.text = groupDetail.groupRunningTime
        introduceLabel.text = groupDetail.groupRunningIntroduce
        print("groupDeatil = \(String(describing: groupDetail.groupName))")
        setRouteAnnotations(startLat: groupDetail.startPointLatitude, startLon: groupDetail.startPointLongitude, endLat: groupDetail.endPointLatitude, endLon: groupDetail.endPointLongitude, mapView: detailMapView)
        helperDraw()
    }
    
    func helperDraw(){
        guard let startLat = groupDetail.startPointLatitude,
            let startLon = groupDetail.startPointLongitude,
            let endLat = groupDetail.endPointLatitude,
            let endLon = groupDetail.endPointLongitude else {
                return
        }
        print("startLat = \(startLat), \(startLon),end = \(endLat), \(endLon)")
        drawLine(startLat: startLat, startLon: startLon, endLat: endLat, endLon: endLon, mapView: detailMapView)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if  segue.identifier == "groupRunningStart"{
            guard let destination = segue.destination as? UINavigationController else{
                return
            }
            guard let runningVC = destination.topViewController as? RunningViewController else {
            return
            }
            runningVC.groupInfo = groupDetail
        
        PrintHelper.println(tag: tag, line: 246, "groupDetail.groupId = \(groupDetail)")
        }else {
            guard let joinPeopleCVC = segue.destination as? JoinPeopleCollectionViewController else{
                return
            }
            joinPeopleCVC.userInfo = groupInfos
        }
    }
}

extension Communicator {
    
    func getJoinInfo(groupId:Int,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : "getJoinInfo",
                                       "groupId" : groupId]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
    
    func insertGroupJoinState(emailAccount:String, groupId:Int, completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : "insertGroupJoinState",
                                       "emailAccount" : emailAccount,
                                       "groupId" : groupId]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
}

extension UIViewController {
    
    //比較兩個日期大小
    func comparisonDate(currentDate:Date, date:Date) ->String{
        
        if currentDate > date {
            return ">"
        }else if currentDate == date {
            return "="
        }else if currentDate < date {
            return "<"
        }else{
            return "wrong"
        }
    }
    
    // MARK: timeNoticeForGroup
    func timeNotice(groupName:String?,groupRunningTime:String? ){
        let content = UNMutableNotificationContent()
        guard let name = groupName else{
            showAlert(message: "通知名稱是空")
            return
        }
        content.title = "\(name),揪團跑即將開始"
        content.subtitle = "請至活動頁面按下開始跑步進行活動"
        content.body = "五分鐘內未開始者視同放棄"
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        
        guard let dataTime = groupRunningTime else{
            return
        }
        print("dataTime = \(dataTime)")
        let date = dateFormatter.date(from: dataTime)
//        print("date = \(date), groupDetail.groupRunningTime = \(groupDetail.groupRunningTime)")
        guard let dateForCalender = date else {
            return
        }
        
        let year = calendar.component(.year, from: dateForCalender)
        let month = calendar.component(.month, from: dateForCalender)
        let day = calendar.component(.day, from: dateForCalender)
        let hour = calendar.component(.hour, from: dateForCalender)
        let min = calendar.component(.minute, from: dateForCalender)
        let sec = calendar.component(.second, from: dateForCalender)
        
        print("year \(year), month \(month), day \(day),hour \(hour), min \(min), sec \(sec)")
        //        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let dateComponents = DateComponents(calendar: Calendar.current, year: year, month: month, day: day, hour: hour, minute: min , second: sec)
        
        //指定時間通知 ！
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "isTime", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
            if let error = error {
                print("UNUserNotificationCenter error:\(error)")
                return
            }
            print("成功建立通知...")
        })
    }
    
}
