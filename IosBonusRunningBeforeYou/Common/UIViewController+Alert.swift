//
//  UIViewController+Alert.swift
//  HelloMyBLE
//
//  Created by Apple on 2018/11/1.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

extension UIViewController{
    func showAlert(title: String? = nil,
                   message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title:"OK", style: .default)
        alert.addAction(ok)
        present(alert,animated: true)
    }

}
