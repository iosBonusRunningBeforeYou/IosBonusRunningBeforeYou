//
//  ExchangeController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/12/6.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ExchangeViewController: UIViewController, UITableViewDelegate {
    
    @IBOutlet weak var userPointLabel: UILabel!
    @IBOutlet weak var couponIdLabel: UILabel!
    @IBOutlet weak var expiredateLabel: UILabel!
    @IBOutlet weak var totalQuantityLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var couponImage: UIImageView!
    @IBOutlet weak var couponQuantity: UITextField!
    @IBOutlet weak var coupnStepper: UIStepper!
    
    let communicator = Communicator.shared
//    let useremail = "8"
    let useremail = "123@gamil.com"
    
    var couponid: String?
    var expiredate: String?
    var totalprice: String?
    var id: Int?
    var couponquantity: Int?
    
    var userpoint: Int?
    var userValid = Bool()
    var nowquantity: Int?
    var textValue: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "兌換資訊確認"
        
        changeDisplay()
        getUserPoint(email: useremail)
        
        isUserValid(email: useremail, id: id! + 1)
        getNowQuantity(email: useremail, id: id! + 1)
        
    }
    
    func changeDisplay() {
        if let couponid = couponid, let expiredate = expiredate, let totalprice = totalprice, let id = id {
            couponIdLabel.text = couponid
            expiredateLabel.text = expiredate
            totalPriceLabel.text = totalprice
            getCouponImage(couponImage, id + 1)

        }
    }
    
    @IBAction func couponStepper(_ sender: UIStepper) {
        textValue = Int(sender.value)   // Stepper回傳的是float所以需要轉成Int
        couponQuantity.text = String(textValue) // Text為文字，所以將數字再轉為字串後顯示
        // UIStepper 最大值
        coupnStepper.maximumValue = Double(couponquantity!)

//        數量為1有點問題 12/7

        totalQuantityLabel.text = couponQuantity.text
        totalPriceLabel.text = String(Int(totalprice!)! * Int(textValue))
    }
    
    @IBAction func cheackBtn(_ sender: UIButton) {
        if Int(userPointLabel.text!)! < (Int(totalprice!)! * textValue) {

        } else {
            // 問題
            if userValid == true {
                getNowQuantity(email: useremail, id: id! + 1)
                updateSumCoupon(email: useremail, id: id! + 1, sumcoupon: Int(couponQuantity.text!)! + nowquantity!)
                print("\(String(describing: totalQuantityLabel.text))")
            } else {
                print("1234")
                // inser
            }
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
    
    func getUserPoint(email: String) { // email 確認一下
        communicator.findTotalPoint(email: email) { (data, error) in
            if let error = error {
                print("Get point error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            
            self.userPointLabel?.text = "\(data)"
            print("Get Point OK.")
            
        }
    }
 
    func isUserValid(email:String, id: Int) {
        communicator.isUserValid(email: email, id: id + 1) { (result, error) in
            if let error = error {
                print("Get point error:\(error)")
                return
            }
            guard let result = result else {
                print("Data is nil")
                return
            }
            
            self.userValid = result as! Bool
        }
    }
    
    func getNowQuantity(email: String, id: Int) { // 取得現有優惠卷比對
        communicator.findNowQuantity(email: email, id: id) { (result, error) in
            if let error = error {
                print("Get Nowquantity error:\(error)")
                return
            }
            guard let result = result else {
                print("Data is nil")
                return
            }
            self.nowquantity = result as? Int
            print("Get Nowquantity OK.")
        }
    }
    
    func updateSumCoupon(email:String, id:Int, sumcoupon: Int) { // 購買已有優惠卷則更新優惠卷數量
        communicator.updateSumCoupon(email: email, id: id, sumcoupon: sumcoupon) { (result, error) in
            if let error = error {
                print("Get updateSumCoupon error:\(error)")
                return
            }
//            guard let result = result else {
//                print("Data is nil")
//                return
//            }
            print("UpdateSumCoupon OK.")
        }
    }
    
    func inserOrder(shop:String) { // 新增購買優惠卷張數
        communicator.inserOrder(shop:shop) { (result, error) in
            if let error = error {
                print("Get InserOrder error:\(error)")
                return
            }
            //            guard let result = result else {
            //                print("Data is nil")
            //                return
            //            }
            print("InserOrder OK.")
        }
    }
    
    func updateTotalPoint() { // 買購買成功扣除User點數
        
    }
    
    func updateCouponData() { // 購買後更改商城優惠卷數量
        
    }
    
    func insertPoint() { // 消費點數存進資料庫
        
    }
    
    // 購買扣點 新增User優惠卷
}

extension Communicator {
    
    func findTotalPoint(eamil:String, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY : "findTotalPoint",
                                       EMAIL_KEY : eamil]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
    func findNowQuantity(email:String, id: Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "findNowQuantity",
                                       EMAIL_KEY: email,
                                       "id_coupon": id]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
    func updateSumCoupon(email:String, id: Int, sumcoupon: Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "updateSumCoupon",
                                       "member_data_email_account": email,
                                       "coupon_data_id_coupon": id,
                                       "sum_coupon": sumcoupon]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
    func isUserValid(email:String, id:Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "userValid",
                                       "member_data_email_account": email,
                                       "coupon_data_id_coupon": id,]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
    func inserOrder(shop:String, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "insertOrder",
                                       shop:"shop"]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
}
