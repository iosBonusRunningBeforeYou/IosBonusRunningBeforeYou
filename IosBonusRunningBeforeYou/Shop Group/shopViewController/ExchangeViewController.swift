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
    @IBOutlet weak var couponImage: UIImageView!
    
    let communicator = Communicator.shared
    
    
    var couponid: String?
    var expiredate: String?
    var totalprice: String?
    var id: Int?
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        changeDisplay()
    }
    
    func changeDisplay() {
        if let couponid = couponid, let expiredate = expiredate, let totalprice = totalprice, let id = id {
            couponIdLabel.text = couponid
            expiredateLabel.text = expiredate
            totalPriceLabel.text = totalprice
            getCouponImage(couponImage, id + 1)

        }
    }
    
    func getCouponImage(_ image:UIImageView,_ id:Int) {
        communicator.getCouponImage(url: communicator.ShopServlet_URL, id: id) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            print("Get Image OK.")
            
            image.image = UIImage(data: data)
        }
    }
    
}
