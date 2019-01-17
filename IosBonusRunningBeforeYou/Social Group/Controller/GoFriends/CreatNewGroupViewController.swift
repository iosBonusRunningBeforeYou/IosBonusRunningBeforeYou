//
//  CreatNewGroupViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/26.
//  Copyright © 2018 Apple. All rights reserved.
//@ Justin

import UIKit
import MapKit

class CreatNewGroupViewController: UIViewController,UITextViewDelegate {
    
    @IBOutlet weak var datePickerView: UIView!
    @IBOutlet weak var timePicker: UIDatePicker!
    @IBOutlet weak var setTimeBtn: UIButton!
    @IBOutlet weak var setLocationBtn: UIButton!
    @IBOutlet weak var groupIntroduceTextView: UITextView!
    @IBOutlet weak var groupNameTextField: UITextField!
    @IBOutlet weak var endPointLabel: UILabel!
    let tag = "CreatNewGroupViewController"
    var userLocation = ""
    var lastLatitude: CLLocationDegrees?
    var lastLongitude: CLLocationDegrees?
    var startLatitude: CLLocationDegrees?
    var startLongitude: CLLocationDegrees?
    var endLatitude: CLLocationDegrees?
    var endLongitude: CLLocationDegrees?
    var newGroup = GoFriendItem()
    let communicator = Communicator.shared
    var results:[Int] = []
    var email = "Lisa@gmail.com"
    let userDefault = UserDefaults.standard

    var isSelectedTextView = false
    var isSelectedTextField = false
    
    var hidden = true{
        didSet{
            datePickerView.isHidden = hidden
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        email = userDefault.string(forKey: "email")!
        groupIntroduceTextView.delegate = self
        
    }
 
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        registerNotification()
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
        groupIntroduceTextView.text = "起點：\(soucr.startIntroduce), 終點：\(soucr.endIntroduce)。"
         PrintHelper.println(tag: tag, line: 65, "unwindToGraetNewGroup: newGroup.startPointLatitude \(newGroup.startPointLatitude), newGroup.startPointLongitude \(newGroup.startPointLongitude), newGroup.endPointLatitude \(newGroup.endPointLatitude), newGroup.endPointLongitude \(newGroup.endPointLongitude)")
    }
    
    @IBAction func timeValueChange(_ sender: UIDatePicker) {

        let time = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyy-MM-dd HH:mm:ss"
        let stringTime = dateFormatter.string(from: time)
        newGroup.groupRunningTime = stringTime

        setTimeBtn.setTitle(stringTime, for: .normal)
        setTimeBtn.setTitleColor(UIColor.black, for: .normal)
        setTimeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 25)
     
    }
    
    @IBAction func timeBtn(_ sender: UIButton) {
        if hidden {
            hidden = false
        }else{
            hidden = true
        }
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "save"{
           
            newGroup.groupName = groupNameTextField.text
            newGroup.groupRunningIntroduce = groupIntroduceTextView.text
            print("prepare = \(newGroup.groupName), \(newGroup.groupRunningTime)")
            timeNotice(groupName: newGroup.groupName, groupRunningTime: newGroup.groupRunningTime)
            //建立新揪團並取得autoId
            communicator.insertNewGroup(newGroup: newGroup) { (result, error) in
                guard let result = result ,let resultInts = result as? [Int] else{
                    print("get joinStatus nil")
                    return
                }
                self.results = resultInts
                if self.results[0] == 1 {
                    PrintHelper.println(tag: self.tag, line: 105, "results = \(self.results[1])")
                    //取到的autoid將主辦人狀態改為參加
                    self.communicator.insertGroupJoinState(email: self.email, groupId: self.results[1]){ (result, error) in
                        if let error = error {
                            print("insertGroupJoinState error:\(error)")
                            return
                        }
                        guard let result = result else {
                            print("insertGroupJoinState result is nil")
                            return
                        }
                        PrintHelper.println(tag: self.tag, line: 116, "insertGroupJoinState output = \(result)")
                        //發出通知，通知首頁資料處理完成重新載入新資料
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "creatGroupOk"), object: 0)
                    }
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
//        PrintHelper.println(tag: tag, line: 201, "prepare: mapVC.startLatitude \(mapVC.startLatitude), mapVC.startLongitude \(mapVC.startLongitude), mapVC.endLatitude \(mapVC.endLatitude), mapVC.endLongitude \(mapVC.endLongitude)")
    }

    
    @objc
    func keyboardState(notification: NSNotification){
        
        if isSelectedTextField == false && isSelectedTextView == false{
            isSelectedTextView = true
        }else if isSelectedTextField == false && isSelectedTextView == true{
            isSelectedTextView = false
        }
    }
    
    //MARK: 註冊鍵盤監聽
  func registerNotification(){
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardState), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardHight), name: UIResponder.keyboardWillShowNotification, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardHight), name: UIResponder.keyboardWillHideNotification, object: nil)
   
    }
    // MARK: 取消監聽鍵盤
    func releaseNotification(){
        NotificationCenter.default.removeObserver(self)
    }
    

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

extension CreatNewGroupViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        isSelectedTextField = true
        isSelectedTextView = false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
          isSelectedTextField = false
    }
}

extension CreatNewGroupViewController {
    //彈出鍵盤時提高畫面
    @objc
    func keyboardHight(_ notification:Notification){
       
            let info = notification.userInfo
            let kbRect = (info?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let offsetY = kbRect.origin.y - UIScreen.main.bounds.height
            UIView.animate(withDuration: 0.1) {
                print("\(offsetY)")
                if offsetY == 0 {
                    self.view.transform = CGAffineTransform(translationX: 0, y: 0)
                }else if  self.isSelectedTextView{
                    self.view.transform = CGAffineTransform(translationX: 0, y: offsetY)
                }
            }
        
    }
}
extension Communicator {
    
    func insertNewGroup(newGroup: GoFriendItem,completion:@escaping DoneHandler){
        let newGroupData = try! JSONEncoder().encode(newGroup)
        let newGroupString = String(data: newGroupData, encoding: .utf8)
        let parameters:[String:Any] = [ACTION_KEY : "insertNewGroup", "goFriendItem": newGroupString as Any]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
    
    func insertGroupJoinState(email:String,groupId:Int,completion:@escaping DoneHandler){
        let parameters:[String:Any] = [ACTION_KEY : "insertGroupJoinState",
                                       "emailAccount" : email,
                                       "groupId" : groupId]
        doPost(urlString: GoFriendsServlet_URL, parameters: parameters, completion:completion)
    }
}
