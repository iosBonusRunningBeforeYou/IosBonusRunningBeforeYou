//
//  RunningViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/11/11.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit
import Alamofire
import UserNotifications
import CoreLocation

class RunningViewController: UIViewController,UNUserNotificationCenterDelegate {
    
    @IBOutlet weak var groupRunningStateField: UILabel!
    @IBOutlet weak var moveLocationField: UIButton!
    
    @IBOutlet weak var imageOfMember: UIImageView!
    
    @IBOutlet weak var playButtonView: UIButton!
    @IBOutlet weak var pauseButtonView: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var kiloMetreLabel: UILabel!
    
    @IBOutlet weak var greenLabel: UILabel!
    @IBOutlet weak var grayLabel: UILabel!
    @IBOutlet weak var blueLabel: UILabel!
    @IBOutlet weak var orangeLabel: UILabel!
    @IBOutlet weak var yellowLabel: UILabel!
    @IBOutlet weak var blackLabel: UILabel!
    
    @IBOutlet weak var greenColorLabel: UILabel!
    @IBOutlet weak var grayColorLabel: UILabel!
    @IBOutlet weak var blueColorLabel: UILabel!
    @IBOutlet weak var orangeColorLabel: UILabel!
    @IBOutlet weak var yellowColorLabel: UILabel!
    @IBOutlet weak var blackColorLabel: UILabel!
    
    var locationmanager = CLLocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    var lastPoint : CLLocationCoordinate2D? = nil
    var newPoint : CLLocationCoordinate2D? = nil
    
    var startLocation: CLLocation!
    var lastLocation : CLLocation!
    var traveledDistance = Double()
    
    var time = 0
    var timer = Timer()
    var isGroupRunngingStartInArea = false
    var isGroupRunngingEndInArea = false
    
    var oldPoint = Double()
    var old_target_daily = Double()
    var old_target_weekly = Double()
    var old_target_monthly = Double()

    @IBOutlet weak var startButtonField: UIButton!
    
    @IBOutlet weak var endButtonField: UIButton!
    
    let communicator = Communicator.shared
    var running = Running()
    var tempUserData = TempUserData()
    var oldCoordinate = StoreAnnotation()
    var firstCoordinate = StoreAnnotation()
    var secondCoordinate = StoreAnnotation()
    var thirdCoordinate = StoreAnnotation()
    var fourthCoordinate = StoreAnnotation()
    var fifthCoordinate = StoreAnnotation()
    var sixthCoordinate = StoreAnnotation()
    
    // Group Running Data
    var groupRunningId = Int()
    var firstGroupMember = GroupMember()
    var firstGroupMail = String()
    
    var secondGroupMember = GroupMember()
    var secondGroupMail = String()
    
    var thirdGroupMember = GroupMember()
    var thirdGroupMail = String()
    
    var fourthGroupMember = GroupMember()
    var fourthGroupMail = String()
    
    var fifthGroupMember = GroupMember()
    var fifthGroupMail = String()
    
    var sixthGroupMember = GroupMember()
    var sixthGroupMail = String()
    
    var pointRecords = PointRecord()
    
    var groupRunningBonus = Int()
    
    // MARK: get info from Game.
    var groupInfo = GoFriendItem()
    var memberArray = Array<String>()
    
    // Boolean to judge polyline color
    var firstNameColor = false
    var secondNameColor = false
    var thirdNameColor = false
    var fourthNameColor = false
    var fifthNameColor = false
    var sixthNameColor = false
    
    // Start & End Location
    var groupStartLocation = Double()
    var groupEndLocation = Double()
    
    var labelArray = Array<UILabel>()
    var accountArray = Array<String>()
    var isShowed = true

    // userDefault
    
    let userDefault = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(getTrack), userInfo: nil, repeats: true)
        
        // userDefault
        running.mail = userDefault.string(forKey: "email")!
        
        print("running.mail: \(running.mail)")
        
        // prepare data for running
        groupRunningId = groupInfo.groupId ?? 0
        groupRunningBonus = 500
        getFakeData()
        print("groupInfo.groupId: \(groupRunningId)")
        
        // Check user in Start area
        isInGroupRunningArea()
        
        // Do any additional setup after loading the view, typically from a nib.
        mainMapView.delegate = self   //Important! 將MKMapViewDelegate的協定,綁在身上.
        
        guard CLLocationManager.locationServicesEnabled() else {
            //show alert to user.
            return
        }
        
    
        // MARK: 判斷是否為揪團跑控制UI顯示.
        labelArray.append(greenLabel)
        labelArray.append(grayLabel)
        labelArray.append(blueLabel)
        labelArray.append(orangeLabel)
        labelArray.append(yellowLabel)
        labelArray.append(blackLabel)
        
        labelArray.append(greenColorLabel)
        labelArray.append(grayColorLabel)
        labelArray.append(blueColorLabel)
        labelArray.append(orangeColorLabel)
        labelArray.append(yellowColorLabel)
        labelArray.append(blackColorLabel)
        
        // Execute moveAndZoomMap() after 3.0 seconds.  //DispatchQueue 是Grant Central DisPath 的應用. //.main 執行在mainQueue
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5 ){
            self.moveAndZoomMap()
        }
        
        // Ask permission.
        locationmanager.requestAlwaysAuthorization()
        locationmanager.requestWhenInUseAuthorization()
        
        // Prepare locationManager.
        
        locationmanager.delegate = self  //Important! 將CLLocationManagerDelegate的協定,綁在身上.
        locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //設定精確度 = (GPS. Wifi 定位,cell定位 擇佳者)
        locationmanager.activityType = .fitness  //位移類型設定 .fitness 用行走的, 也可以選擇其他交通工具.
        locationmanager.startUpdatingLocation() //startUpdatingLocation() 給位置.  startUpdatingHeading() 給羅盤(面向的方向)
        
        notificationCenter.delegate = self
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("NotificationCenter Authorization Granted!")
            }
        }
        
        // Prepare GroupRunning data
        
//        groupRunningId = 9
        if groupRunningId == 0 {
            moveLocationField.isHidden = true
            imageOfMember.isHidden = true
            for label in labelArray{
                label.isHidden = true
            }
        } else {
            
            communicator.getImage(url: communicator.GameDetailServlet_URL, email: running.mail) { (data, error) in
                if let error = error {
                    print("Get image error:\(error)")
                    return
                }
                guard let data = data else {
                    print("Data is nil")
                    return
                }
                self.imageOfMember.image = UIImage(data: data)
                
                print("imageOfMemberjson = \(data)")
//                SVProgressHUD.dismiss()
            }
            
            // Set startLocation and endlocation
            makeStartAndEndAnnotation()
            navigationItem.title = "GroupRunning"
            
            communicator.getGroupEmail(id: groupRunningId) { (result, error) in
                print("getGroupEmail = \(String(describing: result))")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                guard let result = (result as? [String]) else {
                    print("result is nil")
                    return
                }
                print("Get user  OK")
                
                // MARK: let groupMember show on the UI View
                
                for member in result{
                    self.memberArray.append(member)
                }
                
                if let index = self.memberArray.index(of: self.running.mail){
                    
                    self.memberArray.remove(at: index)
                    print("index:\(index),memberArray.count:\(self.memberArray.count)")
                }
            
                if self.memberArray.count == 0{
                    for label in self.labelArray{
                        label.isHidden = true
                    }
                }
            
                if self.memberArray.count == 1 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.firstGroupMail = self.memberArray[0]
                    for label in self.labelArray where (label != self.greenLabel && label != self.greenColorLabel) {
                        label.isHidden = true
                    }
                    
                } else if self.memberArray.count == 2 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.grayLabel.text = self.mailFilter(self.memberArray[1])
                    
                    self.firstGroupMail = self.memberArray[0]
                    self.secondGroupMail = self.memberArray[1]
                    
                    for label in self.labelArray where (label != self.greenLabel && label != self.greenColorLabel &&
                    label != self.grayLabel && label != self.grayColorLabel) {
                        label.isHidden = true
                    }
                    
                } else if self.memberArray.count == 3 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.grayLabel.text = self.mailFilter(self.memberArray[1])
                    self.blueLabel.text = self.mailFilter(self.memberArray[2])
                    
                    self.firstGroupMail = self.memberArray[0]
                    self.secondGroupMail = self.memberArray[1]
                    self.thirdGroupMail = self.memberArray[2]
                    
                    for label in self.labelArray where (label != self.greenLabel && label != self.greenColorLabel &&
                        label != self.grayLabel && label != self.grayColorLabel &&
                        label != self.blueLabel && label != self.blueColorLabel ) {
                            
                            label.isHidden = true
                    }
                    
                } else if self.memberArray.count == 4 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.grayLabel.text = self.mailFilter(self.memberArray[1])
                    self.blueLabel.text = self.mailFilter(self.memberArray[2])
                    self.orangeLabel.text = self.mailFilter(self.memberArray[3])
                    
                    self.firstGroupMail = self.memberArray[0]
                    self.secondGroupMail = self.memberArray[1]
                    self.thirdGroupMail = self.memberArray[2]
                    self.fourthGroupMail = self.memberArray[3]
                    
                    self.yellowLabel.isHidden = true
                    self.yellowColorLabel.isHidden = true
                    self.blackLabel.isHidden = true
                    self.blackColorLabel.isHidden = true
                    
                    
                } else if self.memberArray.count == 5 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.grayLabel.text = self.mailFilter(self.memberArray[1])
                    self.blueLabel.text = self.mailFilter(self.memberArray[2])
                    self.orangeLabel.text = self.mailFilter(self.memberArray[3])
                    self.yellowLabel.text = self.mailFilter(self.memberArray[4])
                    self.firstGroupMail = self.memberArray[0]
                    self.secondGroupMail = self.memberArray[1]
                    self.thirdGroupMail = self.memberArray[2]
                    self.fourthGroupMail = self.memberArray[3]
                    self.fifthGroupMail = self.memberArray[4]
                    
                    self.blackLabel.isHidden = true
                    self.blackColorLabel.isHidden = true
                    
                } else if self.memberArray.count == 6 {
                    
                    self.greenLabel.text = self.mailFilter(self.memberArray[0])
                    self.grayLabel.text = self.mailFilter(self.memberArray[1])
                    self.blueLabel.text = self.mailFilter(self.memberArray[2])
                    self.orangeLabel.text = self.mailFilter(self.memberArray[3])
                    self.yellowLabel.text = self.mailFilter(self.memberArray[4])
                    self.blackLabel.text = self.mailFilter(self.memberArray[5])
                    self.firstGroupMail = self.memberArray[0]
                    self.secondGroupMail = self.memberArray[1]
                    self.thirdGroupMail = self.memberArray[2]
                    self.fourthGroupMail = self.memberArray[3]
                    self.fifthGroupMail = self.memberArray[4]
                    self.sixthGroupMail = self.memberArray[5]
                }

            }
        }
        playButtonView.isHidden = true
        pauseButtonView.isHidden = false
        
        timerLabel.layer.cornerRadius = 7.0
        playButtonView.layer.cornerRadius = 5.0
        pauseButtonView.layer.cornerRadius = 5.0
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RunningViewController.action), userInfo: nil, repeats: true)
        
        let now = Date()
        running.startTime = Int(now.timeIntervalSince1970 * 1000)
        PrintHelper.println(tag: "RunningViewController", line: 154, "Running:groupId = \(groupInfo)")
        
    }
    
    func moveAndZoomMap(){
        
        guard let location = locationmanager.location else{
            print("Location is not ready.")
            return
        }
        
        // Move and zoom the map.
        let span = MKCoordinateSpan(latitudeDelta: 0.0008, longitudeDelta: 0.0008)   //Span 地圖縮放 ()
        let region = MKCoordinateRegion(center: location.coordinate, span: span)  //把span的參數 設定給Region
        mainMapView.setRegion(region, animated: true)
        
        groupRunningJudgement()
    }
    
    
    // MARK: 判斷揪團跑起點終點位置
    func groupRunningJudgement() {
        
        guard let location = locationmanager.location else{
            print("Location is not ready.")
            return
        }
        
        print("groupRunningId:groupRunningId:\(groupRunningId)")
        
        if groupRunningId != 0 {
            guard let startPointLatitude =  groupInfo.startPointLatitude, let startPointLongitude =  groupInfo.startPointLongitude else {
                print("groupInfo.startPoint = nil")
                return
            }
            
            guard let endPointLatitude =  groupInfo.endPointLatitude, let endPointLongitude =  groupInfo.endPointLongitude else {
                print("groupInfo.endPoint = nil")
                return
            }
            
            print("oldCoordinate:\(oldCoordinate)")
            
            // 0.0005 for demo,  0.00008 for recode
            if abs(location.coordinate.latitude - startPointLatitude) < 0.00008,
                abs(location.coordinate.longitude - startPointLongitude) < 0.00008{
                isGroupRunngingStartInArea = true
            }
            
            if abs(location.coordinate.latitude - endPointLatitude) < 0.00008,
                abs(location.coordinate.longitude - endPointLongitude) < 0.00008{
                if  isGroupRunngingStartInArea == true {
                    isGroupRunngingEndInArea = true
                }
            }
            
        }
    }
    
    func makeStartAndEndAnnotation() {
        
        guard let startPointLatitude =  groupInfo.startPointLatitude, let startPointLongitude =  groupInfo.startPointLongitude else {
            print("groupInfo.startPoint = nil")
            return
        }
        
        guard let endPointLatitude =  groupInfo.endPointLatitude, let endPointLongitude =  groupInfo.endPointLongitude else {
            print("groupInfo.endPoint = nil")
            return
        }

        let anns = [MKPointAnnotation(), MKPointAnnotation()]
        
        anns[0].coordinate = CLLocationCoordinate2D(latitude: startPointLatitude,
                                                    longitude: startPointLongitude)
        anns[0].title = "起點的位置"
        
        anns[1].coordinate = CLLocationCoordinate2D(latitude: endPointLatitude,
                                                    longitude: endPointLongitude)
        anns[1].title = "終點的位置"
        
        mainMapView.addAnnotations(anns)
        mainMapView.setCenter(anns[0].coordinate, animated: true)
        
        // show all annotation title.
        mainMapView.selectAnnotation(anns[0], animated: true)
    }

    
    @IBAction func playButton(_ sender: UIButton) {
        
        playButtonView.isHidden = true
        pauseButtonView.isHidden = false
        timer.fireDate = Date.distantPast
        locationmanager.startUpdatingLocation()
    }
    
    @IBAction func pauseButton(_ sender: UIButton) {
        
        pauseButtonView.isHidden = true
        playButtonView.isHidden = false
        timer.fireDate = Date.distantFuture
        locationmanager.stopUpdatingLocation()
        
        if groupRunningId == 0 {
            showAlert()
        } else {
            showGroupAlert()
        }
        
        let now = Date()
        
        running.endTime = Int(now.timeIntervalSince1970 * 1000)
        running.totalTime = Double(running.endTime - running.startTime)
        
        if groupRunningId == 0 {
            let ann = MKPointAnnotation()
            ann.coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude,
                                                    longitude: lastLocation.coordinate.longitude)
            ann.title = "暫停的位置"
            mainMapView.addAnnotation(ann)
            // move map
            mainMapView.setCenter(ann.coordinate, animated: true)
            mainMapView.selectAnnotation(ann, animated: true)
        }
    }
    
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "unwind", sender: self)
    }
    
    
    @objc func action(){
        
        time += 1
        timerLabel.text = transToHourMinSec(time: Float(time))
    }
    
    func showAlert(){
    // 無條件進位
    self.running.points = running.points.rounded( .towardZero)
    let alertText = "您這次獲得了\(Int(running.points))點,\n是否結束此次運動?"
    let alert = UIAlertController(title: alertText , message: "", preferredStyle: .alert)
    
    let ok = UIAlertAction(title: "確定", style: .default){(action) in
        
    // unwind to frontPage
    
        self.performSegue(withIdentifier: "unwind", sender: self)
        
    // upload data to dataBase
        
        print("\(self.running.startTime),\(self.running.endTime)")
        
        let runningData = try! JSONEncoder().encode(self.running)
        let runningString = String(data: runningData, encoding: .utf8)
        self.communicator.insertRunningDataAndPointData(runningData: runningString!, pointData: runningString!){ (result, error) in
            print("insertRunningDataAndPointData = \(String(describing: result))")
        }
        
        // MARK:把點數加到會員資料表 sumToTotalPoint(email,points);
        
        self.communicator.findTotalPoint(email: self.running.mail) {(result, error) in
            print("findTotalPoint = \(String(describing: result))")
            
            if let error = error {
                print("Get point error:\(error)")
                return
            }
            guard let result = result else {
                print("point is nil")
                return
            }
            self.oldPoint = result as! Double
            print("\(self.oldPoint)")
            self.running.points += self.oldPoint
            print("\(self.running.points)")
            
            self.communicator.updateTotalPoint(email: self.running.mail, totalPoint: Int(self.running.points)) { (result, error) in
                print("updateTotalPoint = \(String(describing: result))")
            }
        }
        
        // MARK:把公里數加到每日、每週、每月的會員資料表. sumToTotalmetra(email);
        
        self.communicator.findByEmail (email: self.running.mail) {(result, error) in
            print("findByEmail = \(String(describing: result))")
            
            if let error = error {
                print("Get user error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get user  OK")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode(TempUserData.self, from: jsonDate) else
            {
                print("Fail to decode jsonData.")
                return
            }
            
                self.tempUserData.target_daily = resultObject.target_daily + self.traveledDistance
                self.tempUserData.target_weekly = resultObject.target_weekly + self.traveledDistance
                self.tempUserData.target_monthly = resultObject.target_monthly + self.traveledDistance
            
                let runningData = try! JSONEncoder().encode(self.tempUserData)
                let runningString = String(data: runningData, encoding: .utf8)
                self.communicator.updateTarget(email: self.running.mail, user: runningString!){ (result, error) in
                    print("updateTarget = \(String(describing: result))")
                }
        }
    }
    
    let cancel = UIAlertAction(title: "取消", style: .destructive){(action) in
    //...
    }
    
    alert.addAction(ok)
       
    alert.addAction(cancel)
        
    present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
   
    func showEndInArea() {
        locationmanager.stopUpdatingLocation()
        let alertText = "恭喜您~終點已到達."
        let alert = UIAlertController(title: alertText, message: "請按下方停止紐結束運動,獲取點數", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default) { (action) in
        }
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
    
    func showGroupAlert(){
        // 無條件進位
        self.running.points = running.points.rounded( .towardZero)
        
        if isGroupRunngingEndInArea == false{
            groupRunningBonus = 0
        }
        
        let alertText = "此次跑步+揪團跑點數,共獲得了\(Int(running.points) + groupRunningBonus)點,\n是否結束此次運動?"
        let alert = UIAlertController(title: alertText , message: "", preferredStyle: .actionSheet)
        
        let ok = UIAlertAction(title: "確定", style: .default){(action) in
            
            // unwind to frontPage
            self.getFakeData()
            self.performSegue(withIdentifier: "unwind", sender: self)
            
            // upload data to dataBase
            print("\(self.running.startTime),\(self.running.endTime)")
            self.running.points = self.running.points + Double(self.groupRunningBonus)
            let runningData = try! JSONEncoder().encode(self.running)
            let runningString = String(data: runningData, encoding: .utf8)
            self.communicator.insertRunningDataAndPointData(runningData: runningString!, pointData: runningString!){ (result, error) in
                print("insertRunningDataAndPointData = \(String(describing: result))")
            }
            
            // MARK: 把揪團跑點數加到點數資料表.
            
            self.pointRecords.record_points = Int(self.running.points) + self.groupRunningBonus
            
            print("self.pointRecords.record_points :\(self.pointRecords.record_points)")
            self.communicator.insertPointData(pointRecords: self.pointRecords) { (result, error) in
                print("insertPointData = \(String(describing: result))")
            }
            
            // MARK: 把跑步點數與揪團跑點數, 加到會員資料表.
            self.communicator.findTotalPoint(email: self.running.mail) {(result, error) in
                print("findTotalPoint = \(String(describing: result))")
                
                if let error = error {
                    print("Get point error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("point is nil")
                    return
                }
                
                self.oldPoint = result as! Double
                print("\(self.oldPoint)")
                
                self.running.points += self.oldPoint
                self.pointRecords.record_points += Int(self.oldPoint)
                
                let totalPoint = Int(self.running.points) + self.pointRecords.record_points
                print("\(self.running.points)")
                
                self.communicator.updateTotalPoint(email: self.running.mail, totalPoint: Int(self.running.points)) { (result, error) in
                    print("updateGroupRunuingTotalPoint = \(String(describing: result))")
                }
                
                self.communicator.updateTotalPoint(email: self.running.mail, totalPoint: totalPoint) { (result, error) in
                    print("updateTotalPoint of GroupRunning = \(String(describing: result))")
                }
                
            }
            
            // MARK:把公里數加到每日、每週、每月的會員資料表. sumToTotalmetra(email);
            
            self.communicator.findByEmail (email: self.running.mail) {(result, error) in
                print("findByEmail = \(String(describing: result))")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get user  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode(TempUserData.self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                self.tempUserData.target_daily = resultObject.target_daily + self.traveledDistance
                self.tempUserData.target_weekly = resultObject.target_weekly + self.traveledDistance
                self.tempUserData.target_monthly = resultObject.target_monthly + self.traveledDistance
                
                let runningData = try! JSONEncoder().encode(self.tempUserData)
                let runningString = String(data: runningData, encoding: .utf8)
                self.communicator.updateTarget(email: self.running.mail, user: runningString!){ (result, error) in
                    print("updateTarget = \(String(describing: result))")
                }
            }
        }
        
        let cancel = UIAlertAction(title: "取消", style: .destructive){(action) in
            //...
        }
        
        alert.addAction(ok)
        
        alert.addAction(cancel)
        
        present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
    
    func isInGroupRunningArea(){
        if groupRunningId == 0 {
            groupRunningStateField.isHidden = true
            startButtonField.isHidden = true
            endButtonField.isHidden = true
            
        } else if isGroupRunngingStartInArea == false{
            groupRunningStateField.text = "尚未到達起點哦！"
        } else {
            groupRunningStateField.text = "到達起點了!"
            groupRunningStateField.backgroundColor = UIColor.green
            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                self.groupRunningStateField.isHidden = true
            }
        }
    }
    
    // Notification user that he was not in correct position.
    // 12/15 擔心起點在座標原點附近,會阻擋掉訊息,而不呼叫此方法. 但保留此方法.
    func showNotInAreaAlert(){
        
        let alertText = "您目前不在揪團跑起點範圍內."
        let alert = UIAlertController(title: alertText , message: "\n請移動您至起點的位置.\n\n再按下 確定 .\n\n左下角◉,可移動到現在位置.", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default){(action) in}
        
        
        alert.addAction(ok)
        
        present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
    
    // Notification user that he was in correct position.
    func showInAreaAlert(){
        
        let alertText = "您已在揪團跑起點範圍內."
        let alert = UIAlertController(title: alertText , message: "可以開始跟朋友開始跑步了!", preferredStyle: .alert)
        
        let ok = UIAlertAction(title: "確定", style: .default){(action) in
            
        }
        
        alert.addAction(ok)
        present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
    
    
    // MARK: - Mapkit delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        if groupRunningId != 0 {
            
            if firstNameColor {
                renderer.strokeColor = UIColor.green
            } else if secondNameColor{
                renderer.strokeColor = UIColor.lightGray
            } else if thirdNameColor{
                renderer.strokeColor = UIColor.blue
            } else if fourthNameColor{
                renderer.strokeColor = UIColor.orange
            } else if fifthNameColor{
                renderer.strokeColor = UIColor.yellow
            } else if sixthNameColor{
                renderer.strokeColor = UIColor.black
            } else {
                renderer.strokeColor = UIColor.red
            }
            
        } else {
            renderer.strokeColor = UIColor.red
        }
        
        renderer.lineWidth = 7.0
        return renderer
    }
    
    
    // MARK: - 把秒数转换成时分秒（00:00:00）格式
    /// - Parameter time: time(Float格式)
    /// - Returns: String格式(00:00:00)
    
    func transToHourMinSec(time: Float) -> String
    {
        let allTime = Int(time)
        var hours = 0
        var minutes = 0
        var seconds = 0
        var hoursText = ""
        var minutesText = ""
        var secondsText = ""
        
        hours = allTime / 3600
        hoursText = hours > 9 ? "\(hours)" : "0\(hours)"
        
        minutes = allTime % 3600 / 60
        minutesText = minutes > 9 ? "\(minutes)" : "0\(minutes)"
        
        seconds = allTime % 3600 % 60
        secondsText = seconds > 9 ? "\(seconds)" : "0\(seconds)"
    
        return "\(hoursText):\(minutesText):\(secondsText)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getFakeData() {
        
        if groupRunningId == 0 {
            self.running.name = "跑步"
        } else {
            self.running.name = "揪團跑"
        }
        
        self.running.id = 1
        self.tempUserData.email_account = self.running.mail
        self.pointRecords.email = self.running.mail
        self.pointRecords.record_name = "揪團跑"
        self.pointRecords.record_date = String(self.running.endTime)

    }
    
    func runningNotice(){
        let content = UNMutableNotificationContent()
        content.title = "🤩"
        content.badge = 1
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(identifier: "timeNotice", content: content, trigger: nil)
        
        UNUserNotificationCenter.current().add(request) {error in
            if let error = error {
                print("UNUserNotificationCenter error:\(error)")
                return
            }
            print("成功建立通知...")
        }
    }
    
    @IBAction func locationButtonPressed(_ sender: UIButton) {
        
        moveAndZoomMap()
    }
    
    @IBAction func startButtonPressed(_ sender: Any) {
        guard let startPointLatitude =  groupInfo.startPointLatitude, let startPointLongitude =  groupInfo.startPointLongitude else {
            print("groupInfo.startPoint = nil")
            return
        }
        
        guard let endPointLatitude =  groupInfo.endPointLatitude, let endPointLongitude =  groupInfo.endPointLongitude else {
            print("groupInfo.endPoint = nil")
            return
        }
        
        let anns = [MKPointAnnotation(), MKPointAnnotation()]
        
        anns[0].coordinate = CLLocationCoordinate2D(latitude: startPointLatitude,
                                                    longitude: startPointLongitude)
        anns[0].title = "起點的位置"
        
        anns[1].coordinate = CLLocationCoordinate2D(latitude: endPointLatitude,
                                                    longitude: endPointLongitude)
        anns[1].title = "終點的位置"
        
        mainMapView.setCenter(anns[0].coordinate, animated: true)
        

    }
    
    @IBAction func endButtonPressed(_ sender: Any) {
        guard let startPointLatitude =  groupInfo.startPointLatitude, let startPointLongitude =  groupInfo.startPointLongitude else {
            print("groupInfo.startPoint = nil")
            return
        }
        
        guard let endPointLatitude =  groupInfo.endPointLatitude, let endPointLongitude =  groupInfo.endPointLongitude else {
            print("groupInfo.endPoint = nil")
            return
        }
        
        let anns = [MKPointAnnotation(), MKPointAnnotation()]
        
        anns[0].coordinate = CLLocationCoordinate2D(latitude: startPointLatitude,
                                                    longitude: startPointLongitude)
        anns[0].title = "起點的位置"
        
        anns[1].coordinate = CLLocationCoordinate2D(latitude: endPointLatitude,
                                                    longitude: endPointLongitude)
        anns[1].title = "終點的位置"
        
        mainMapView.setCenter(anns[1].coordinate, animated: true)

    }
    
}
//擴充,可以讓各協定(Protocols),做拆分的動作. (以便放在自創.swift中)
// MARK : - MKMapViewDelegate Methods.
extension RunningViewController  :  MKMapViewDelegate {
    
    //將圖示改為大頭針.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ //用is檢查型別
            return nil
        }
        
//        guard let annotation = annotation as? StoreAnnotation else{
//            assertionFailure("Fail to cast as StoreAnnotation.") //assertionFailure, DEBUG用, 用來看不該出現的問題. 不影響使用者.
//            return nil
//        }
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annView == nil{
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        annView?.image = UIImage(named: "pointRed.png")
        annView?.canShowCallout = true
        return annView
    }
}

extension RunningViewController : CLLocationManagerDelegate{
    //MARK : -CLLocationManagerDelegate Methods.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let coordinate = locations.last?.coordinate else{
            assertionFailure("Invaild coordinate or location.")  //assertionFailure, DEBUG用, 用來看不該出現的問題. 不影響使用者.
            return
        }
        // MARK: FOR RECORD
//        moveAndZoomMap()
        groupRunningJudgement()
        
        // Check user in Start area
        isInGroupRunningArea()
        
        if isGroupRunngingEndInArea == true {
            showEndInArea()
            locationmanager.stopUpdatingLocation()
        }
        
        if isGroupRunngingStartInArea == true, isShowed == true {
            
            showInAreaAlert()
            isShowed = false
        }
        
        // MARK: get distance Data
        if startLocation == nil {
            startLocation = locations.first
            
        } else if let location = locations.last {
            
            traveledDistance += lastLocation.distance(from: location)
            
            running.points = traveledDistance / 10
            
            traveledDistance = traveledDistance.rounded(.towardZero)
            
            // MARK: Preparefor DEMO
            if groupRunningId == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 15 ){
                    self.kiloMetreLabel.text = "\(3000/1000) 公里"
                    self.traveledDistance = 3000
                }
            } else {
                self.kiloMetreLabel.text = "\(self.traveledDistance/1000) 公里"
            }
        }
        lastLocation = locations.last
        
        print ("Current Location :  \(coordinate.latitude), \(coordinate.longitude)")
        
        // get Data to upload
        running.latitude = coordinate.latitude
        running.longitude = coordinate.longitude
        running.distance = traveledDistance
        let now = Date()
        running.time = Int(now.timeIntervalSince1970 * 1000 )
        
        // upload to server
        getFakeData()

        communicator.insertRunning(running: self.running) {(result, error) in
        print("runningInsert = \(String(describing: result))")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
            self.draw2D(coordinate: coordinate)
        }
        
        getTrack()
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "arsegue" {
            let controller = segue.destination as! ARViewController
            controller.kiloMeter = traveledDistance
        }
    }
    
    @objc func getTrack() {
        
        if groupRunningId != 0 {
            
            self.communicator.getTrackByMail(email: firstGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.firstGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.firstGroupMember.id = data.id
                    self.firstGroupMember.latitude = data.latitude
                    self.firstGroupMember.longitude = data.longitude
                    print("data.endTime,data.startTime:\(data.endTime), \(data.startTime)")
                }
                
            }
            
            // secondMember
            self.communicator.getTrackByMail(email: secondGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.secondGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.secondGroupMember.id = data.id
                    self.secondGroupMember.latitude = data.latitude
                    self.secondGroupMember.longitude = data.longitude
                }
            }
            
            // thirdMember
            self.communicator.getTrackByMail(email: thirdGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.thirdGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.thirdGroupMember.id = data.id
                    self.thirdGroupMember.latitude = data.latitude
                    self.thirdGroupMember.longitude = data.longitude
                }
            }
            
            // fourthMember
            self.communicator.getTrackByMail(email: fourthGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.fourthGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.fourthGroupMember.id = data.id
                    self.fourthGroupMember.latitude = data.latitude
                    self.fourthGroupMember.longitude = data.longitude
                }
            }
            
            // fifthMember
            self.communicator.getTrackByMail(email: fifthGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.fifthGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.fifthGroupMember.id = data.id
                    self.fifthGroupMember.latitude = data.latitude
                    self.fifthGroupMember.longitude = data.longitude
                }
            }
            
            // sixthMember
            self.communicator.getTrackByMail(email: sixthGroupMail){ (result, error) in
                print("getTrackByMail = \(String(describing: result))")
                print("firstGroupMail:\(self.sixthGroupMail)")
                
                if let error = error {
                    print("Get user error:\(error)")
                    return
                }
                
                guard let result = result else {
                    print("result is nil")
                    return
                }
                print("Get track  OK")
                
                guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                    print("Fail to generate jsonData.")
                    return
                }
                let decoder = JSONDecoder()
                guard let resultObject = try? decoder.decode([GroupMember].self, from: jsonDate) else
                {
                    print("Fail to decode jsonData.")
                    return
                }
                
                for data in resultObject{
                    self.sixthGroupMember.id = data.id
                    self.sixthGroupMember.latitude = data.latitude
                    self.sixthGroupMember.longitude = data.longitude
                }
            }
            
            print("groupRunningId:\(groupRunningId)")
            drawGroup2D()
        }
    }
    
    @objc func drawGroup2D() {
        let now = Date()
        if groupRunningId != 0 {
            // today's date
            let todayFormatter = DateFormatter()
            todayFormatter.dateFormat = "dd"
            
            // groupRunning date
            let groupRunningToday = groupInfo.groupRunningTime ?? "2018-12-16  08:07:17"
            let dayStart = groupRunningToday.index(groupRunningToday.startIndex, offsetBy: 08)
            let dayEnd = groupRunningToday.index(dayStart, offsetBy: 1)
            let today = groupRunningToday[dayStart...dayEnd]
            
            // check it.
            print("String(describing time: \(todayFormatter.string(from: now)), \(today)")
            print("true or false : \((todayFormatter.string(from: now)) == today)")
            
            if todayFormatter.string(from: now) == today {
                
                let oldFirstCoordinate = CLLocationCoordinate2DMake(self.firstGroupMember.latitude, self.firstGroupMember.longitude)
                self.drawFirstMember2D(coordinate: oldFirstCoordinate)
                
                let oldsecondCoordinate = CLLocationCoordinate2DMake(self.secondGroupMember.latitude, self.secondGroupMember.longitude)
                self.drawSecondMember2D(coordinate: oldsecondCoordinate)
                
                let oldthirdCoordinate = CLLocationCoordinate2DMake(self.thirdGroupMember.latitude, self.thirdGroupMember.longitude)
                self.drawThirdMember2D(coordinate: oldthirdCoordinate)
                
                let oldfourthCoordinate = CLLocationCoordinate2DMake(self.fourthGroupMember.latitude, self.fourthGroupMember.longitude)
                self.drawFourthMember2D(coordinate: oldfourthCoordinate)
                
                let oldfifthCoordinate = CLLocationCoordinate2DMake(self.fifthGroupMember.latitude, self.fifthGroupMember.longitude)
                self.drawFifthMember2D(coordinate: oldfifthCoordinate)
                
                let oldsixthCoordinate = CLLocationCoordinate2DMake(self.sixthGroupMember.latitude, self.sixthGroupMember.longitude)
                self.drawSixthMember2D(coordinate: oldsixthCoordinate)
            }
        }
    }
    
    func draw2D(coordinate: CLLocationCoordinate2D) {
        
        if oldCoordinate.coordinate.latitude != 0.0 && oldCoordinate.coordinate.longitude != 0.0 {
            
            let polyline = MKPolyline(coordinates: [coordinate, oldCoordinate.coordinate], count: 2)
            self.mainMapView.addOverlay(polyline)

        }
        oldCoordinate.coordinate = coordinate
    }
    
    func drawFirstMember2D(coordinate: CLLocationCoordinate2D ) {
        
        // first
        firstNameColor = true
        if firstGroupMember.latitude != 0 && firstGroupMember.longitude != 0 {
            if coordinate.latitude != firstCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, firstCoordinate.coordinate], count: 2)
                if firstCoordinate.coordinate.latitude != 0{
                self.mainMapView.addOverlay(polyline)
                }
            }
        }
        firstCoordinate.coordinate = coordinate
        firstNameColor = false
    }
    
     func drawSecondMember2D(coordinate: CLLocationCoordinate2D ) {
        // second
        secondNameColor = true
        if secondGroupMember.latitude != 0 && secondGroupMember.longitude != 0 {
            if coordinate.latitude != secondCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, secondCoordinate.coordinate], count: 2)
                if secondCoordinate.coordinate.latitude != 0{
                    self.mainMapView.addOverlay(polyline)
                }
            }
        }
        secondCoordinate.coordinate = coordinate
        secondNameColor = false
    }
    
    func drawThirdMember2D(coordinate: CLLocationCoordinate2D ) {
        // third
        thirdNameColor = true
        if thirdGroupMember.latitude != 0 && thirdGroupMember.longitude != 0 {
            if coordinate.latitude != thirdCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, thirdCoordinate.coordinate], count: 2)
                if thirdCoordinate.coordinate.latitude != 0{
                    self.mainMapView.addOverlay(polyline)
                }
            }
        }
        thirdCoordinate.coordinate = coordinate
        thirdNameColor = false
    }
    
    func drawFourthMember2D(coordinate: CLLocationCoordinate2D ) {
        // fourth
        fourthNameColor = true
        if fourthGroupMember.latitude != 0 && fourthGroupMember.longitude != 0 {
            if coordinate.latitude != fourthCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, fourthCoordinate.coordinate], count: 2)
                if fourthCoordinate.coordinate.latitude != 0{
                    self.mainMapView.addOverlay(polyline)
                }
            }
        }
        fourthCoordinate.coordinate = coordinate
        fourthNameColor = false
    }
    
    func drawFifthMember2D(coordinate: CLLocationCoordinate2D ) {
        // fifth
        fifthNameColor = true
        if fifthGroupMember.latitude != 0 && fifthGroupMember.longitude != 0 {
            if coordinate.latitude != fifthCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, fifthCoordinate.coordinate], count: 2)
                if fifthCoordinate.coordinate.latitude != 0{
                    self.mainMapView.addOverlay(polyline)
                }
            }
        }
        fifthCoordinate.coordinate = coordinate
        fifthNameColor = false
    }
    
    func drawSixthMember2D(coordinate: CLLocationCoordinate2D ) {
        // sixth
        sixthNameColor = true
        if sixthGroupMember.latitude != 0 && sixthGroupMember.longitude != 0 {
            if coordinate.latitude != sixthCoordinate.coordinate.latitude {
                let polyline = MKPolyline(coordinates: [coordinate, sixthCoordinate.coordinate], count: 2)
                if sixthCoordinate.coordinate.latitude != 0{
                    self.mainMapView.addOverlay(polyline)
                }
            }
        }
        sixthCoordinate.coordinate = coordinate
        sixthNameColor = false
    }
    
    func mailFilter(_ input :String) -> String {
        
        var newStr = String()
        if input.contains("@gamil.com"){
            newStr = input.replacingOccurrences(of: "@gamil.com", with: "")
            print("replacingOccurrences:\(newStr)")
            return newStr
        } else {
            newStr = input.replacingOccurrences(of: "@gmail.com", with: "")
            print("replacingOccurrences:\(newStr)")
            return newStr
        }
        
    }

}


extension Communicator{
    
    func insertRunningDataAndPointData(runningData: String , pointData: String ,completion:@escaping DoneHandler){
        
        // startTime, endTime, totalTime ,distance, email
        
        let parameters:[String:Any] = [ACTION_KEY : "runningDataInsert","runningData": runningData, "pointData": pointData]
        doPost(urlString: RunningDataServlet_URL, parameters: parameters, completion:completion)
    }
    
    func insertRunning(running: Running ,completion:@escaping DoneHandler){
        
        // time, latitude, longitude, id;
        let runningData = try! JSONEncoder().encode(running)
        let runningString = String(data: runningData, encoding: .utf8)
        
        let parameters:[String:Any] = [ACTION_KEY : "runningInsert","running":runningString as Any]
        doPost(urlString: RunningServlet_URL, parameters: parameters, completion:completion)
        
    }
    
    func insertPointData(pointRecords: PointRecord ,completion:@escaping DoneHandler){
        
        // record_name, record_points, record_date, email_account;
        let pointData = try! JSONEncoder().encode(pointRecords)
        let pointString = String(data: pointData, encoding: .utf8)
        
        let parameters:[String:Any] = [ACTION_KEY : "insert","pointData":pointString as Any]
        doPost(urlString: PointsRecordServlet_URL, parameters: parameters, completion:completion)
    }
    
    func findTotalPoint(email: String ,completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "findTotalPoint","email":email]
        doPost(urlString: PointsRecordServlet_URL, parameters: parameters, completion:completion)
    }
    
    func updateTotalPoint(email: String, totalPoint: Int,completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "updateTotalPoint", "email": email , "totalPoint": totalPoint ]
        doPost(urlString: PointsRecordServlet_URL, parameters: parameters, completion:completion)
    }
    
    func findByEmail(email: String ,completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "findByEmail","email":email]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }

    func updateTarget(email: String, user:String ,completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "updateTarget", "user": user]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
    func getGroupEmail(id: Int ,completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "getMailById", "group_running_id_group_running": id]
        doPost(urlString: RunningDataServlet_URL, parameters: parameters, completion:completion)
    }
    
    func getTrackByMail(email: String ,completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY : "getTrackByMail", "member_data_email_account": email]
        doPost(urlString: RunningServlet_URL, parameters: parameters, completion:completion)
    }
    
}

//Protocol 利用.
class StoreAnnotation :NSObject, MKAnnotation{
    //Basic properties
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2DMake(0, 0) //語法上要給予起始值.
    var title : String?
    var subtitle: String?
    
    override init(){
        super.init()
        
    }
    
}
