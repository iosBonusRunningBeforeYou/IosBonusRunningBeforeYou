//
//  ExchangeController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/12/6.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController {
    
    @IBOutlet weak var userPointLabel: UILabel!
    @IBOutlet weak var couponIdLabel: UILabel!
    @IBOutlet weak var expiredateLabel: UILabel!
    @IBOutlet weak var totalQuantityLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    
    var couponid: String?
    var expiredate: String?
    var totalprice: String?

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        changeDisplay()
    }
    
    func changeDisplay() {
        if let couponid = couponid, let expiredate = expiredate, let totalprice = totalprice {
            couponIdLabel.text = couponid
            expiredateLabel.text = expiredate
            totalPriceLabel.text = totalprice
            
            print("\(couponid)")
        }
    }
    
}
