//
//  MapViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/27.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

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
            setRouteAnnotations(startLat: startLatitude, startLon: startLongitude, endLat: endLatitude, endLon: endLongitude, mapView: setLocationMapView)
            
            guard let startLat = self.startLatitude, let startLon = self.startLongitude,
                let endLat = self.endLatitude, let endLon = self.endLongitude else{
                    return
            }
            drawLine(startLat: startLat, startLon: startLon, endLat: endLat, endLon: endLon, mapView: setLocationMapView)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if startLatitude == nil && startLongitude == nil &&
            endLatitude == nil && endLongitude == nil {
            // 現在的時間往後3秒執行裡面程式
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0){
                //取得user位置並放大顯示
                self.moveAndZoomMap(self.locationManager, self.setLocationMapView,0.01,0.01)
            }
        }
    }
    
    @IBAction func goBtnAction(_ sender: UIButton) {
        guard let startLat = self.startLatitude, let startLon = self.startLongitude,
            let endLat = self.endLatitude, let endLon = self.endLongitude else{
                return
        }
        drawLine(startLat: startLat, startLon: startLon, endLat: endLat, endLon: endLon, mapView: setLocationMapView)
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


