//
//  MapHelperViewControlle.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/30.
//  Copyright © 2018 Apple. All rights reserved.
//
//  @Justin
// 導航兩點間畫線 ,帶入起點及終點的經緯度
//

import UIKit
import MapKit

extension UIViewController {
    
    //取得user位置並放大顯示
    func moveAndZoomMap (_ locationManager:CLLocationManager,_ mapView:MKMapView,
                         _ latDelta:CLLocationDegrees,_ lonDelta:CLLocationDegrees) {
        guard let location = locationManager.location else {
            print("Location is not ready")
            return
        }
        //設定縮放大圖的大小,但通常是兩個值寫一樣 讓底下的MKCoordinateRegion 後面的程式判斷比例大小
        let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        //設定地點
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    //設起終點座標
    func setRouteAnnotations(startLat:CLLocationDegrees?, startLon:CLLocationDegrees?, endLat:CLLocationDegrees?,endLon:CLLocationDegrees?,mapView:MKMapView){
        
        guard let startLat = startLat, let startLon = startLon,
        let endLat = endLat, let endLon = endLon else {
            return
        }
        let startAnnotation = MKPointAnnotation()
        startAnnotation.coordinate = CLLocationCoordinate2D(latitude: startLat, longitude: startLon)
        let endAnnotation = MKPointAnnotation()
        endAnnotation.coordinate = CLLocationCoordinate2D(latitude: endLat, longitude: endLon)
        mapView.addAnnotations([startAnnotation, endAnnotation])  
    }
    //兩點導航畫線
    func drawLine(startLat:CLLocationDegrees, startLon:CLLocationDegrees, endLat:CLLocationDegrees,endLon:CLLocationDegrees,mapView:MKMapView ){
        
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
            mapView.addOverlay(route.polyline, level: .aboveLabels)
            let rect = route.polyline.boundingMapRect
            mapView.setRegion(MKCoordinateRegion(rect), animated: true)
        }
    }  
}
extension MapViewController {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
}

extension GroupDeatilViewController {
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        renderer.lineWidth = 4.0
        return renderer
    }
}
