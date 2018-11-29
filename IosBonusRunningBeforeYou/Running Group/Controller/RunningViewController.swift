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

class RunningViewController: UIViewController {
    
    @IBOutlet weak var playButtonView: UIButton!
    @IBOutlet weak var pauseButtonView: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var mainMapView: MKMapView!
    @IBOutlet weak var kiloMetreLabel: UILabel!
    
    var locationmanager = CLLocationManager()
    var lastPoint : CLLocationCoordinate2D? = nil
    var newPoint : CLLocationCoordinate2D? = nil
    
    
    var startLocation: CLLocation!
    var lastLocation : CLLocation!
    var traveledDistance = Double()
    
    var time = 0
    var timer = Timer()

    var oldPoint = Double()
    var old_target_daily = Double()
    var old_target_weekly = Double()
    var old_target_monthly = Double()

    
    let communicator = Communicator.shared
    var running = Running()
    var tempUserData = TempUserData()
    var oldCoordinate = StoreAnnotation()
    
    // Group Running Data
    var groupRunningId = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        mainMapView.delegate = self   //Important! 將MKMapViewDelegate的協定,綁在身上.
        guard CLLocationManager.locationServicesEnabled() else {
            //show alert to user.
            return
        }
        
        // Execute moveAndZoomMap() after 3.0 seconds.  //DispatchQueue 是Grant Central DisPath 的應用. //.main 執行在mainQueue
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5 ){
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
        
        // Prepare GroupRunning data
        getFakeData()
        communicator.getGroupEmail(id: groupRunningId) { (result, error) in
            print("getGroupEmail = \(String(describing: result))")
            
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
        
        
        playButtonView.isHidden = true
        pauseButtonView.isHidden = false
        
        timerLabel.layer.cornerRadius = 7.0
        playButtonView.layer.cornerRadius = 5.0
        pauseButtonView.layer.cornerRadius = 5.0
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RunningViewController.action), userInfo: nil, repeats: true)
        

        let now = Date()
        running.startTime = Int(now.timeIntervalSince1970 * 1000)
        
    }
    
    func moveAndZoomMap(){
        
        guard let location = locationmanager.location else{
            print("Location is not ready.")
            return
        }
        
        // Move and zoom the map.
        let span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)   //Span 地圖縮放 ()
        
        let region = MKCoordinateRegion(center: location.coordinate, span: span)  //把span的參數 設定給Region
        mainMapView.setRegion(region, animated: true)
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
        showAlert()
        
        let now:Date = Date()
        
        running.endTime = Int(now.timeIntervalSince1970 * 1000)
        running.totalTime = Double(running.endTime - running.startTime)
        
        let ann = MKPointAnnotation()
        ann.coordinate = CLLocationCoordinate2D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude)
        ann.title = "暫停的位置"
        mainMapView.addAnnotation(ann)
        // move map
        mainMapView.setCenter(ann.coordinate, animated: true)
    }
    
    @IBAction func CancelPressed(_ sender: UIBarButtonItem) {
        
        showAlert()
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
    
    // MARK: - Mapkit delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 6.0
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
        self.running.mail = "234@gmail.com"
        self.running.password = "234"
        self.running.name = "Chris"
        self.running.id = 1
        self.tempUserData.email_account = self.running.mail
        groupRunningId = 1
    }
    
    @IBAction func unwindTOList(_ segue: UIStoryboardSegue){
//        groupRunningStart
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
        
        var annView = mapView.dequeueReusableAnnotationView(withIdentifier: "Pin")
        if annView == nil{
            annView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Pin")
        }
        
        annView?.image = UIImage(named: "when_running_finish.png")
        
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
        
        // MARK: get distance Data
        if startLocation == nil {
            startLocation = locations.first
            
        } else if let location = locations.last {
            
            traveledDistance += lastLocation.distance(from: location)
            
            running.points = traveledDistance / 10
            
            traveledDistance = traveledDistance.rounded(.towardZero)
            kiloMetreLabel.text = "\(traveledDistance/1000) 公里"
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

        let runningData = try! JSONEncoder().encode(self.running)
        let runningString = String(data: runningData, encoding: .utf8)
        communicator.insertRunning(running: runningString!) {(result, error) in
        print("runningInsert = \(String(describing: result))")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1 ){
            self.draw2D(coordinate: coordinate)
        }
    }
    
    func draw2D(coordinate: CLLocationCoordinate2D) {
        
        if oldCoordinate.coordinate.latitude != 0.0 && oldCoordinate.coordinate.longitude != 0.0 {
            
            let polyline = MKPolyline(coordinates: [coordinate, oldCoordinate.coordinate], count: 2)
            self.mainMapView.addOverlay(polyline)

        }
        oldCoordinate.coordinate = coordinate
    }
    
    func drawGroup2D(coordinate: CLLocationCoordinate2D ) {
        
        if oldCoordinate.coordinate.latitude != 0.0 && oldCoordinate.coordinate.longitude != 0.0 {
            
            let polyline = MKPolyline(coordinates: [coordinate, oldCoordinate.coordinate], count: 2)
            self.mainMapView.addOverlay(polyline)
            
        }
        oldCoordinate.coordinate = coordinate
    }

}


extension Communicator{
    
    func insertRunningDataAndPointData(runningData: String , pointData: String ,completion:@escaping DoneHandler){
        
        // startTime, endTime, totalTime ,distance, email
        
        let parameters:[String:Any] = [ACTION_KEY : "runningDataInsert","runningData": runningData, "pointData": pointData]
        doPost(urlString: RunningDataServlet_URL, parameters: parameters, completion:completion)
        
    }
    
    func insertRunning(running: String ,completion:@escaping DoneHandler){
        
        // time, latitude, longitude, id;
        
        let parameters:[String:Any] = [ACTION_KEY : "runningInsert","running":running]
        doPost(urlString: RunningServlet_URL, parameters: parameters, completion:completion)
        
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
        
        let parameters:[String:Any] = [ACTION_KEY : "findByGroupId", "group_running_id_group_running": id]
        doPost(urlString: RunningDataServlet_URL, parameters: parameters, completion:completion)
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
