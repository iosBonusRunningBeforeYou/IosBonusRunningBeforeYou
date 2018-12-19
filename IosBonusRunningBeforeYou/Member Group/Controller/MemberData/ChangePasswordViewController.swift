//
//  ChangePasswordViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var oldPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmPassword: UITextField!
    
    let communicator = Communicator.shared
    let userDefaults = UserDefaults.standard
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        email = userDefaults.string(forKey: "email")!
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(closeKeyboard))
        view.addGestureRecognizer(tap)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.performSegue(withIdentifier: "changePasswordUnfinish", sender: nil)
    }
    
    @objc func closeKeyboard() {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func changePassword(_ sender: Any) {
        
        if (oldPassword.text == "" || newPassword.text == "" || confirmPassword.text == "") {
            errorMessageLabel.text = "所有欄位皆不可為空值!!"
            return
        }
        
        communicator.isUserValid(email: email, password: oldPassword.text!) { (result, error) in
            print("isUserValid = \(String(describing: result))")
            
            if let error = error {
                print("Get user error:\(error)")
                self.errorMessageLabel.text = "請重新輸入"
                return
            }
            
            if result as! Bool {
                if (self.newPassword.text == self.confirmPassword.text) {
                    self.communicator.changePassword(email: self.email, password: self.newPassword.text!, completion: { (result, error) in
                        print("changePasswordResult = \(String(describing: result))")
                        
                        if let error = error {
                            print("Get user error:\(error)")
                            self.errorMessageLabel.text = "變更密碼失敗"
                            return
                        }
                        
                        if (result as! Int == 0) {
                            self.errorMessageLabel.text = "變更密碼失敗"
                            return
                        }
                        else {
                            self.performSegue(withIdentifier: "changePasswordSuccessful", sender: nil)
                        }
                    })
                }
                else {
                    self.errorMessageLabel.text = "新密碼2次輸入不一致!!"
                    return
                }
            }
            else {
                self.errorMessageLabel.text = "舊密碼輸入錯誤!!"
            }
            
        }
    }

}

extension Communicator {
    
    func changePassword(email: String, password: String, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "changepassword", "email": email, "newpassword": password]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
}
