//
//  UseMyCouponViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/12.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class UseMyCouponViewController: UIViewController {

    @IBOutlet weak var couponNameLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var qrcodeImageView: UIImageView!
    @IBOutlet weak var finishBtn: UIButton!
    
    let communicator = Communicator.shared
    let userDefaults = UserDefaults.standard
    var couponName = String()
    var couponID = Int()
    var couponAmount = Int()
    var deadLine = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        couponNameLabel.text = couponName
        deadlineLabel.text = deadLine

        // Do any additional setup after loading the view.
    }
    
    @IBAction func finishBtnPressed(_ sender: UIButton) {
        
        communicator.updateMyCoupon(email: userDefaults.string(forKey: "email")!, id: couponID, amount: couponAmount-1) { (result, error) in
            print("updateResult = \(String(describing: result))")
            
            if let error = error {
                print("Update MyCoupon error:\(error)")
                return
            }
            
            if (result as! Int == 0) {
                return
            }
            else {
                self.performSegue(withIdentifier: "useCouponSuccessful", sender: nil)
            }
            
        }
        
    }

}

extension Communicator {
    
    func updateMyCoupon(email: String, id: Int, amount: Int, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "updateSumCoupon", "member_data_email_account": email, "coupon_data_id_coupon": id, "sum_coupon": amount]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion:completion)
    }
    
}
