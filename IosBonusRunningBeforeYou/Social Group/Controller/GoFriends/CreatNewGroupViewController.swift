//
//  CreatNewGroupViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/26.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import MapKit

class CreatNewGroupViewController: UIViewController {
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var setTimeBtn: UIButton!
    @IBOutlet weak var setLocationBtn: UIButton!
    @IBOutlet weak var groupIntroduceTextView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!
    let tag = "CreatNewGroupViewController"
    var userLocation = ""
    var lastLatitude: CLLocationDegrees?
    var lastLongitude: CLLocationDegrees?
    var newGroup = GoFriendItem()
    var startLatitude: CLLocationDegrees?
    var startLongitude: CLLocationDegrees?
    var endLatitude: CLLocationDegrees?
    var endLongitude: CLLocationDegrees?
    @IBOutlet weak var endPointLabel: UILabel!
    let communicator = Communicator.shared
    var results:[Int] = []
    let email = "123@gamil.com"
    
    var hidden = true{
        didSet{
            datePickerView.isHidden = hidden
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
  
    }
    
    @IBAction func unwindToGraetNewGroup(_ segue: UIStoryboardSegue){
        guard  segue.identifier == "saveLocation"  else {
            return
        }
        guard let soucr = segue.source as? MapViewController else {
            return
        }
        startLatitude = soucr.startLatitude
        startLongitude = soucr.startLongitude
        endLatitude = soucr.endLatitude
        endLongitude = soucr.endLongitude

        newGroup.startPointLatitude = startLatitude
        newGroup.startPointLongitude = startLongitude
        newGroup.endPointLatitude = endLatitude
        newGroup.endPointLongitude = endLongitude
        groupIntroduceTextView.text += "起點：\(soucr.startIntroduce), 終點：\(soucr.endIntroduce)。"
//        setLocationBtn.setTitle(showLocationInfo(latitude: startLatitude, longitude: startLongitude), for: .normal)
//        setLocationBtn.setTitleColor(UIColor.black, for: .normal)
//        setLocationBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
//        endPointLabel.text = showLocationInfo(latitude: endLatitude, longitude: endLongitude)
    
    }
    
    @IBAction func timeValueChange(_ sender: UIDatePicker) {
        print("chick\(timePicker.date)")
        print("sender = \(sender.locale) date = \(sender.date) calendar = \(String(describing: sender.calendar)) timeZone = \(String(describing: sender.timeZone))")
        let time = sender.date
        print("time = \(time)")
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        var stringTime = dateFormatter.string(from: time)
        
        
        //        str.substring(with: str.index(str.startIndex, offsetBy: 7) ..< str.index(str.endIndex, offsetBy: -6)) // play
        
        //取字串中的字
        let sty = stringTime[stringTime.index(stringTime.startIndex, offsetBy: 5) ..< stringTime.index(stringTime.startIndex, offsetBy: 7)]
        
        
        print("stringTime \(stringTime) sty = \(sty)")
        
        newGroup.groupRunningTime = stringTime

        setTimeBtn.setTitle(stringTime, for: .normal)
        setTimeBtn.setTitleColor(UIColor.black, for: .normal)
        setTimeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
       print("setTimeBtn.currentTitle = \(setTimeBtn.currentTitle)")
     
    }
    @IBAction func groupNameEditingChanged(_ sender: UITextField) {
        
        
    }
    
    @IBAction func timeBtn(_ sender: UIButton) {
        
        if hidden {
            hidden = false
        }else{
            hidden = true
        }
    }
    
    @IBAction func saveToDBAction(_ sender: UIBarButtonItem) {
  
        
    }
    func showLocationInfo(latitude: CLLocationDegrees?, longitude: CLLocationDegrees? ) ->String {
        //經緯度查住址
        let geocoder = CLGeocoder()
        guard let lat = latitude ,let lon = longitude else{
            return ""
        }
        let targetLocation = CLLocation(latitude: lat, longitude: lon)
        
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
            
            
        }
        return self.userLocation
    }
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "save"{
            newGroup.groupName = groupNameTextField.text
            newGroup.groupRunningIntroduce = groupIntroduceTextView.text
            communicator.insertNewGroup(newGroup: newGroup) { (result, error) in
                guard let result = result ,let resultInts = result as? [Int] else{
                    print("get joinStatus nil")
                    return
                }
                
                self.results = resultInts
                
                if self.results[0] == 1{
                    PrintHelper.println(tag: self.tag, line: 170, "results = \(self.results[1])")
                    self.communicator.insertGroupJoinState(email: self.email, groupId: self.results[1], completion: { (result, error) in
                        if let error = error {
                            print("insertGroupJoinState error:\(error)")
                            return
                        }
                        guard let result = result else {
                            print("insertGroupJoinState result is nil")
                            return
                        }
                        PrintHelper.println(tag: self.tag, line: 180, "insertGroupJoinState output = \(result)")
                    })
                    
                }else {
                    print("insertNewGroup wrong")
                }
                
            }
        }
        
        guard let mapVC = segue.destination as? MapViewController else {
            return
        }

        mapVC.startLatitude = startLatitude
        mapVC.startLongitude = startLongitude
        mapVC.endLatitude = endLatitude
        mapVC.endLongitude = endLongitude
        
    }
    

}

extension Communicator {
    
    func insertNewGroup(newGroup: GoFriendItem,completion:@escaping DoneHandler){
        let newGroupData = try! JSONEncoder().encode(newGroup)
        let newGroupString = String(data: newGroupData, encoding: .utf8)
        let parameters:[String:Any] = [ACTION_KEY : "insertNewGroup","goFriendItem": newGroupString as Any]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
    func insertGroupJoinState(email:String,groupId:Int,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : "insertGroupJoinState",
                                       "emailAccount" : email,
                                       "groupId" : groupId]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
    
    
    
}
