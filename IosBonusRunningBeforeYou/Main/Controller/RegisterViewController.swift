//
//  RegisterViewController.swift
//  HelloLogin
//
//  Created by Edward on 2018/12/6.
//  Copyright © 2018 OverLove. All rights reserved.
//

import UIKit
import Alamofire


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var maleBtn: RadioButton!
    @IBOutlet weak var femaleBtn: RadioButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    let communicator = Communicator.shared
    var userData = UserData()
    let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()

        maleBtn.isSelected = true
        userData.gender = 1
        femaleBtn.isSelected = false
        
        
    }
    
    @IBAction func maleBtnPressed(_ sender: RadioButton) {
        sender.isSelected = true
        femaleBtn.isSelected = false
        userData.gender = 1
    }
    
    @IBAction func femaleBtnPressed(_ sender: RadioButton) {
        sender.isSelected = true
        maleBtn.isSelected = false
        userData.gender = 2
    }
    
    
    @IBAction func emailTextAction(_ sender: UITextField) {

        communicator.isUserExist(email: emailTextField.text!) { (result, error) in
            print("isUserExist = \(String(describing: result))")
            
            if let error = error {
                print("Get user error:\(error)")
                self.errorMessage.text = "請重新輸入!!"
                return
            }
            
            if result as! Bool {
                self.errorMessage.text = "該帳號已經存在!!"
                self.errorMessage.textColor = UIColor.red
            }
            else {
                self.errorMessage.text = "該帳號可以使用!!"
                self.errorMessage.textColor = UIColor.black
            }
    
        }
    }
    
    func convertImageToBase64() -> String {
        
//        let imageData = image.jpegData(compressionQuality: 100)!
        let imageData = UIImage(named: "default photo")!.jpegData(compressionQuality: 100)!
        return imageData.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
        
    }
    
    @IBAction func registerBtnPressed(_ sender: UIButton) {
        if (emailTextField.text == "" || passwordTextField.text == "" || confirmTextField.text == "" || nameTextField.text == "" || ageTextField.text == "" || heightTextField.text == "" || weightTextField.text == "") {
            self.errorMessage.text = "所有欄位皆不可為空值!!"
            self.errorMessage.textColor = UIColor.red
            return
        }
        
        if (passwordTextField.text != confirmTextField.text) {
            self.errorMessage.text = "新密碼2次輸入不一致!!"
            self.errorMessage.textColor = UIColor.red
            return
        }
        else {
            self.userData.email_account = emailTextField.text!
            self.userData.password = passwordTextField.text!
            self.userData.name = nameTextField.text!
            self.userData.age = Int(ageTextField.text!)!
            self.userData.height = Int(heightTextField.text!)!
            self.userData.weight = Float(weightTextField.text!)!
        }
        
        communicator.registerUser(userData: userData) { (result, error) in
            print("registerResult = \(String(describing: result))")
            
            if let error = error {
                print("Get user error:\(error)")
                self.errorMessage.text = "註冊失敗"
                self.errorMessage.textColor = UIColor.red
                return
            }
            
            if (result as! Int == 0) {
                self.errorMessage.text = "註冊失敗"
                self.errorMessage.textColor = UIColor.red
                return
            }
            else {
                self.userDefaults.set(self.userData.email_account, forKey: "email")
                self.userDefaults.synchronize()
                
                    
                let imageBase64 =  self.convertImageToBase64()
                self.communicator.updatePhoto(email: self.userDefaults.string(forKey: "email")!, imageBase64: imageBase64) { (result, error) in
                    print("updateResult = \(String(describing: result))")
                    
                    if let error = error {
                        print("Update userPhoto error:\(error)")
                        return
                    }
                    
                    if (result as! Int == 0) {
                        return
                    }
                
                }
                
                self.performSegue(withIdentifier: "registerSuccessful", sender: nil)   // 接 running
            }
        }
        
    }

}

extension Communicator{
    
    
    func isUserExist(email: String, completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "userExist","email": email]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
    func registerUser(userData: UserData, completion:@escaping DoneHandler) {
        let userData = try! JSONEncoder().encode(userData)
        let userDataString = String(data: userData, encoding: .utf8)
        let parameters:[String:String] = [ACTION_KEY : "insert","user": userDataString!]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
}
