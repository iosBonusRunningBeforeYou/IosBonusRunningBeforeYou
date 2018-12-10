//
//  ViewController.swift
//  HelloLogin
//
//  Created by OverLove on 2018/10/3.
//  Copyright © 2018 OverLove. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorMessage: UILabel!
    
    let communicator = Communicator.shared
    var userData = UserData()
    let userDefaults = UserDefaults.standard
    var email = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        email = userDefaults.string(forKey: "email")!
        if (email != nil) {
            self.performSegue(withIdentifier: "loginSuccessful", sender: nil)   // 接 running
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        errorMessage.text = ""
    }

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        let username = userNameTextField.text
        let password = passwordTextField.text
        if (username == "" || password == "") {
            self.errorMessage.text = "所有欄位皆不可為空值!!"
            return
        }
        
        communicator.isUserValid(email: username!, password: password!) { (result, error) in
            print("isUserValid = \(String(describing: result))")
            
            if let error = error {
                print("Get user error:\(error)")
                self.errorMessage.text = "錯誤的帳號或密碼"
                return
            }
            
            if result as! Bool {
                self.userDefaults.set(username, forKey: "email")
                self.userDefaults.synchronize()
                self.performSegue(withIdentifier: "loginSuccessful", sender: nil)   // 接 running
            }
            else {
                self.errorMessage.text = "錯誤的帳號或密碼"
            }
            
        }
        
    }
    
    @IBAction func unwindToLogin(segue: UIStoryboardSegue) {
        
    }
}

extension Communicator{
    
    func isUserValid(email: String, password: String, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "userValid", "email": email, "password": password]
        doPost(urlString: UserServlet_URL, parameters: parameters, completion:completion)
    }
    
}

