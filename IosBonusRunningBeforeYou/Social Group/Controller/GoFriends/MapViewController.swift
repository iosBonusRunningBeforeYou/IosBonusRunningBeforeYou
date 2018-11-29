//
//  MapViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/27.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var setLocationMapView: MKMapView!
    @IBOutlet weak var startPointLabel: UILabel!
    @IBOutlet weak var endPointLabel: UILabel!
    let tag = "MapViewController"
    var userLocation: String = ""
    var startIntroduce = ""
    var endIntroduce = ""
    var count = 0
    var lastLatitude: CLLocationDegrees?
    var lastLongitude: CLLocationDegrees?
    var startLatitude: CLLocationDegrees?
    var startLongitude: CLLocationDegrees?
    var endLatitude: CLLocationDegrees?
    var endLongitude: CLLocationDegrees?
    let locationManager = CLLocationManager()
    
    var int = 0 {
        didSet{
            switch int {
            case 1:
                startLatitude = lastLatitude
                startLongitude = lastLongitude
                print("in5t = \(startLatitude), \(startLongitude)")
                guard let lat = startLatitude , let lon = startLongitude else{
                    return
                }
                showLocationInfo(latitude: lat, longitude: lon)
            case 2:
                endLatitude = lastLatitude
                endLongitude = lastLongitude
                print("in5t = \(endLatitude), \(endLongitude)")
                guard let lat = endLatitude , let lon = endLongitude else{
                    return
                }
                showLocationInfo(latitude: lat, longitude: lon)
            default:
                return
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //確認user是否有啟用定位服務
        guard CLLocationManager.locationServicesEnabled() else {
            // Show alert to user
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
        setLocationMapView.delegate = self
        
        if startLatitude != nil && startLongitude != nil &&
            endLatitude != nil && endLongitude != nil {
            let startAnnotation = MKPointAnnotation()
            startAnnotation.coordinate = CLLocationCoordinate2D(latitude: startLatitude!, longitude: startLongitude!)
            let endAnnotation = MKPointAnnotation()
            endAnnotation.coordinate = CLLocationCoordinate2D(latitude: endLatitude!, longitude: endLongitude!)
            self.setLocationMapView.addAnnotations([startAnnotation, endAnnotation])
            drawLine()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 現在的時間往後3秒執行裡面程式
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
            self.moveAndZoomMap()
        }
    }
    //取得user位置並放大顯示
    func moveAndZoomMap () {
            guard let location = locationManager.location else {
                print("Location is not ready")
                return
            }
            //設定縮放大圖的大小,但通常是兩個值寫一樣 讓底下的MKCoordinateRegion 後面的程式判斷比例大小
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            //設定地點
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            setLocationMapView.setRegion(region, animated: true)
    }
    @IBAction func goBtnAction(_ sender: UIButton) {
        drawLine()
    }
    
    func drawLine(){
        guard let startLat = self.startLatitude, let startLon = self.startLongitude,
            let endLat = self.endLatitude, let endLon = self.endLongitude else{
                return
        }
        let lastStartPoint = CLLocationCoordinate2D(latitude: startLat , longitude: startLon)
        let lastEndPoint = CLLocationCoordinate2D(latitude: endLat, longitude : endLon)
        
        let sourcePlaceMark = MKPlacemark(coordinate: lastStartPoint)
        let destinationPlaceMark = MKPlacemark(coordinate: lastEndPoint)
        
        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlaceMark)
        directionRequest.destination = MKMapItem(placemark: destinationPlaceMark)
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate { (response, error) in
            guard let directionResonse = response else {
                if let error = error {
                    print("we have error getting directions == \(error.localizedDescription)")
                }
                return
            }
            let route = directionResonse.routes[0]
            self.setLocationMapView.addOverlay(route.polyline, level: .aboveLabels)
            let rect = route.polyline.boundingMapRect
            self.setLocationMapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
    @IBAction func removeAllAnnotations(_ sender: UIButton) {
        setLocationMapView.removeAnnotations(setLocationMapView.annotations)
        setLocationMapView.removeOverlays(setLocationMapView.overlays)
        startPointLabel.text?.removeAll()
        endPointLabel.text?.removeAll()
    }

    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        if setLocationMapView.annotations.count <= 2 {
            if sender.state == .began{
                
                let location = sender.location(in: self.setLocationMapView)
                
                let locCooard = self.setLocationMapView.convert(location, toCoordinateFrom: self.setLocationMapView)
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = locCooard
                
                setLocationMapView.addAnnotation(annotation)
                print("location = \(location), locCooard = \(locCooard.latitude), \(locCooard.longitude)")
                
                lastLatitude = locCooard.latitude
                lastLongitude = locCooard.longitude
            }
        }
    }
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        lastLatitude = view.annotation?.coordinate.latitude
        lastLongitude = view.annotation?.coordinate.longitude
        
        let alertController = UIAlertController(
            title: "規劃路線",
            message: "",
            preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        alertController.addAction(cancelAction)
      
        let startAction = UIAlertAction(title: "起點", style: .default) { (action: UIAlertAction!) in
            self.int = 1 }
        alertController.addAction(startAction)
        let endAction = UIAlertAction(title: "終點", style: .default) { (action: UIAlertAction!) in
            self.int = 2 }
        alertController.addAction(endAction)
        let removeAnnotationAction = UIAlertAction(title: "移除座標", style: .default) { (action: UIAlertAction!) in
            self.setLocationMapView.removeAnnotation(view.annotation!)
        }
        alertController.addAction(removeAnnotationAction)
        // 顯示提示框
        self.present(alertController, animated: true, completion: nil)
    }

    func setAnnotation(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {

        self.setLocationMapView.removeAnnotations(setLocationMapView.annotations)
        let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)

            self.setLocationMapView.addAnnotation(annotation)
        lastLatitude = latitude
        lastLongitude = longitude
    }
    
    func showLocationInfo(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        //經緯度查住址
        let geocoder = CLGeocoder()
        let targetLocation = CLLocation(latitude: latitude, longitude: longitude)
        
        geocoder.reverseGeocodeLocation(targetLocation) { (plackmarks  , error ) in
            if let error = error{
                print("geocodeAddressString fail : \(error)")
                return
            }
            //如果得到空值就印出。   optional chain 可選鍊 把所有可選型別併在一起判斷 可以讓程式更精練 plackmarks?.first?.location?.coordinate
            guard let placemark = plackmarks?.first else{
                    assertionFailure("plackmarks is empty or nil.")
                    return
            }
//            print("country 國名 = \(placemark.country), locality 區 = \(placemark.locality), sublocality = \(placemark.subLocality), name 路名門牌號碼= \(placemark.name),thoroughfare 路名=  \(placemark.thoroughfare), subThoroughfare 門牌號碼 = \(placemark.subThoroughfare), administrativeArea 國家= \(placemark.administrativeArea), subAdministrativeArea 市= \(placemark.subAdministrativeArea) inlandWater 河,溪名稱= \(placemark.inlandWater), ocean = \(placemark.ocean), areasOfInterest 山區 = \(placemark.areasOfInterest)")
            
            guard let subAdministrativeArea = placemark.subAdministrativeArea else{
                return
            }
            guard let locality = placemark.locality else {
                return
            }
            guard let name = placemark.name else{
                return
            }
            self.userLocation = "\(subAdministrativeArea), \(locality), \(name)"
            if self.int == 1{
                self.startPointLabel.text = self.userLocation
                self.startIntroduce += self.userLocation
            }else if self.int == 2{
                self.endPointLabel.text = self.userLocation
                self.endIntroduce += self.userLocation
            }
            
        }
    }
}

//extension MapViewController : MKMapViewDelegate{
//    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
//        let coordinate = mapView.region.center
//        print("Map Center:\(coordinate.latitude),\(coordinate.longitude)")
//        if count == 0 && lastLatitude != nil && lastLongitude != nil {
//            showLocationInfo(latitude: lastLatitude!, longitude: lastLongitude!)
////            setAnnotation(latitude: lastLatitude!, longitude: lastLongitude!)
//            count += 1
//        }else{
//        showLocationInfo(latitude: coordinate.latitude, longitude: coordinate.longitude)
////        setAnnotation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        }
//    }
//
//
//
//}
//
