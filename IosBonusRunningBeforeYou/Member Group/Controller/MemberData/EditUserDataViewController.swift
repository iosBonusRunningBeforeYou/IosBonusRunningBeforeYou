//
//  EditUserDataViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class EditUserDataViewController: UIViewController {
    
    @IBOutlet weak var errorMessage: UILabel!
    @IBOutlet weak var editNameTextField: UITextField!
    @IBOutlet weak var editAgeTextField: UITextField!
    @IBOutlet weak var editHeightTextField: UITextField!
    @IBOutlet weak var editWeightTextField: UITextField!
    
    let communicator = Communicator.shared
    var userData = UserData()
    let userDefaults = UserDefaults.standard
    var email = String()
    var name = String()
    var age = Int()
    var height = Int()
    var weight = Float()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = userDefaults.string(forKey: "email")!
        name = userDefaults.string(forKey: "name")!
        age = userDefaults.integer(forKey: "age")
        height = userDefaults.integer(forKey: "height")
        weight = userDefaults.float(forKey: "weight")
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        editNameTextField.text = name
        editAgeTextField.text = String(age)
        editHeightTextField.text = String(height)
        editWeightTextField.text = String(weight)
        
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func finishBtnPressed(_ sender: UIButton) {
        
        if (editNameTextField.text == "" || editAgeTextField.text == "" || editHeightTextField.text == "" || editWeightTextField.text == "") {
            self.errorMessage.text = "所有欄位皆不可為空值!!"
            return
        }
        
        self.userData.email_account = email
        self.userData.name = editNameTextField.text!
        self.userData.age = Int(editAgeTextField.text!)!
        self.userData.height = Int(editHeightTextField.text!)!
        self.userData.weight = Float(editWeightTextField.text!)!
        
        communicator.updateUserData(userData: userData) { (result, error) in
            print("updateResult = \(String(describing: result))")
            
            if let error = error {
                print("Update userData error:\(error)")
                self.errorMessage.text = "上傳資料失敗"
                return
            }
            
            if (result as! Int == 0) {
                self.errorMessage.text = "上傳資料失敗"
                return
            }
            else {
                self.performSegue(withIdentifier: "updateUserDataSuccessful", sender: nil)
            }
            
        }
        
    }

}

extension Communicator {
    
    func updateUserData(userData: UserData, completion: @escaping DoneHandler) {
        
        let userData = try! JSONEncoder().encode(userData)
        let userDataString = String(data: userData, encoding: .utf8)
        let parameters:[String:Any] = [ACTION_KEY : "updateData", "user": userDataString!]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
}

