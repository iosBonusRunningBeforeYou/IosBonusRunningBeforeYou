//
//  RunningViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/11/11.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit

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
    var lastLocation: CLLocation!
    var traveledDistance: Double = 0
    
    var time = 0
    var timer = Timer()
    
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
        
        //Prepare locationManager.
        locationmanager.delegate = self  //Important! 將CLLocationManagerDelegate的協定,綁在身上.
        locationmanager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters //設定精確度 = (GPS. Wifi 定位,cell定位 擇佳者)
        locationmanager.activityType = .fitness  //位移類型設定 .fitness 用行走的, 也可以選擇其他交通工具.
        locationmanager.startUpdatingLocation() //startUpdatingLocation() 給位置.  startUpdatingHeading() 給羅盤(面向的方向)
        
        
        playButtonView.isHidden = true
        pauseButtonView.isHidden = false
        
        timerLabel.layer.cornerRadius = 7.0
        playButtonView.layer.cornerRadius = 5.0
        pauseButtonView.layer.cornerRadius = 5.0
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(RunningViewController.action), userInfo: nil, repeats: true)
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
    }
    
    
    
    //    @IBAction func reset(_ sender: Any) {
    //
    //        time = 0
    //        timeScreen.text = "0"
    //    }
    
    @objc func action(){
        
        time += 1
        timerLabel.text = transToHourMinSec(time: Float(time))
    }
    
    
    // MARK: - Mapkit delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 10.0
        return renderer
    }
    
    // MARK: - 把秒数转换成时分秒（00:00:00）格式
    ///
    /// - Parameter time: time(Float格式)
    /// - Returns: String格式(00:00:00)
    
    func transToHourMinSec(time: Float) -> String
    {
        let allTime: Int = Int(time)
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
}


//擴充,可以讓各協定(Protocols),做拆分的動作. (以便放在自創.swift中)
// MARK : - MKMapViewDelegate Methods.
extension RunningViewController  :  MKMapViewDelegate {
    
    //當地圖的region被改變時 regionDidChangeAnimated 就會被呼叫.
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let coordinate = mapView.region.center
        print("Map Center: \(coordinate.latitude), \(coordinate.longitude)")
    }
    
    //將圖示改為大頭針.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation{ //用is檢查型別
            return nil
        }
        
        //用自創的Protocol 簽協定.
        //annotation as? StoreAnnotation(轉型)
        //Cast annotation as StoreAnnotation type.
        guard let annotation = annotation as? StoreAnnotation else{
            assertionFailure("Fail to cast as StoreAnnotation.") //assertionFailure, DEBUG用, 用來看不該出現的問題. 不影響使用者.
            return nil
        }
        let identifier = "store"
        //到dequeueReusableAnnotationView回收機制中, 找View.
        //identifier 的設計是for唯一的識別使用.
        var result = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) //as? MKPinAnnotationView(將大頭針換成圖示 step1) //轉型.
        if result == nil{
            //            result = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            result = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }else{
            result?.annotation = annotation
        }
        result?.canShowCallout = true
        //        result?.pinTintColor = .blue //(將大頭針換成圖示 step2)
        //        result?.animatesDrop = true
        
        let image = UIImage(named: "pointRed.png") //(將大頭針換成圖示 step3)
        result?.image = image   //(將大頭針換成圖示 step3)
        
        // Left-calloutaccessoryview.
        let imageView = UIImageView(image: image)
        result?.leftCalloutAccessoryView = imageView
        
        // Right-calloutaccessoryview.
        let button  = UIButton(type: .detailDisclosure) //detailDisclosure apple內建紐之一
        // 用程式碼建立touchUpInside的監聽.
        button.addTarget(self, action: #selector(accessoryBtnPressed(sender:)), for: .touchUpInside)  //這是IBAcion平常幫我們做的事情.
        result?.rightCalloutAccessoryView = button
        
        return result
    }
    
    @objc
    func accessoryBtnPressed(sender : Any){
        //.alert .actionSheet, 選項少訊息多時, 用.alert.  選項多訊息少時,用.actionSheet.
        let alertText = "即將前往\(title ?? "")的位置"
        let alert = UIAlertController(title: alertText , message: "導航前往這個地點? (若地點不正確,則會導航至台北市館前路45號)", preferredStyle: .alert)
        //        let ok = UIAlertAction(title: "ok", style: .default , handler: nil)
        
        //((action) in 的後面放要做的事情)
        let ok = UIAlertAction(title: "ok", style: .default){(action) in
            
        }
        let cancel = UIAlertAction(title: "Cancel", style: .destructive){(action) in
            //...
        }
        
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil) // present由下往上跳全螢幕.
    }
}


extension RunningViewController : CLLocationManagerDelegate{
    //MARK : -CLLocationManagerDelegate Methods.
    // 每個Protocol 第一個參數,都會放自己本身.  locations: [CLLocation] 當位置改變時, apple的CPU 在閒暇時, 把點存進[CLLocation]中.(最後面的最新)
    //didUpdateLocations 只有在位置改變時, 才會存點.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let coordinate = locations.last?.coordinate else{
            assertionFailure("Invaild coordinate or location.")  //assertionFailure, DEBUG用, 用來看不該出現的問題. 不影響使用者.
            return
        }
        
        // get distance Data
        
        if startLocation == nil {
            startLocation = locations.first
            
        } else if let location = locations.last {
            
            traveledDistance += lastLocation.distance(from: location)
            kiloMetreLabel.text = "\(Int(traveledDistance)) 公尺"
        }
        lastLocation = locations.last
        
        print ("Current Location :  \(coordinate.latitude), \(coordinate.longitude)")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3 ){
            self.draw2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        
    }
    
    func draw2D(latitude: Double , longitude: Double ) {
        
        newPoint = CLLocationCoordinate2D(latitude: latitude , longitude: longitude)
        
        if (lastPoint == nil) {
            lastPoint = newPoint;
        }
        
        let sourceLocation = lastPoint
        let destinationLocation = newPoint
        let sourcePlaceMark = MKPlacemark(coordinate: sourceLocation!)
        let destinationPlaceMark = MKPlacemark(coordinate: destinationLocation!)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions==\(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.mainMapView.addOverlay(route.polyline, level: .aboveLabels)
            // Set to zoomin
            //        let rect = route.polyline.boundingMapRect
            //        self.mainMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
        lastPoint = newPoint
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


