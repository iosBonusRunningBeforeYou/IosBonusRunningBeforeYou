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
    @IBOutlet weak var cheackBtn: UIButton!
    @IBOutlet weak var couponStepper: UIStepper!
    
    let communicator = Communicator.shared
//    let useremail = "444"
    var useremail = ""
    var now:Date = Date()
    let userDefault = UserDefaults.standard
    
    var couponid: String?
    var expiredate: String?
    var totalprice: String?
    var id: Int?
    var couponquantity: Int?
    
    var userpoint: Int?
    var userValid = Bool()
    var nowquantity: Int?
    var textValue: Int = 0
    var nowpoint: Int = 0
    var updatequantity: Int = 0
    
    var pointRecords = PointsRecord()
    
    var order = Order()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "兌換資訊確認"
        // userDefault
        useremail = userDefault.string(forKey: "email")!
        
        changeDisplay()
        getUserPoint(email: useremail)
        isUserValid(email: useremail, id: id! + 1)
        getNowQuantity(email: useremail, id: id! + 1)
        print(now)
        
        if couponquantity! <= 0 {
            self.view.showToast(text: "剩餘數量不足，無法兌換")
            cheackBtn.isEnabled = false
            cheackBtn.alpha = 0.4
            coupnStepper.isEnabled = false
        }
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
        
        if Int(userPointLabel.text!)! < (Int(totalprice!)! * textValue) {
            self.view.showToast(text: "點數不足，無法兌換")
            cheackBtn.isEnabled = false
            cheackBtn.alpha = 0.4
        } else {
            cheackBtn.isEnabled = true
            cheackBtn.alpha = 1
            self.view.hideToast()
        }
    }
    
    @IBAction func cheackBtn(_ sender: UIButton) {
        if couponquantity! <= 0 {
            
        } else {
            if Int(userPointLabel.text!)! < (Int(totalprice!)! * textValue) {
                
            } else {
                if userValid == true {
                    getNowQuantity(email: useremail, id: id! + 1)
                    updateSumCoupon(email: useremail, id: id! + 1, sumcoupon: Int(couponQuantity.text!)! + nowquantity!)
                    print("\(String(describing: totalQuantityLabel.text))")
                } else {
                    
                    // inserorder 新增購買優惠卷張數
                    self.order.useremail = useremail
                    self.order.id = id! + 1
                    self.order.totalquantity = Int(totalQuantityLabel.text!)!
                    
                    let orderRecordData = try! JSONEncoder().encode(self.order)
                    let orderRecordString = String(data: orderRecordData, encoding: .utf8)
                    communicator.inserOrder(shop: orderRecordString!) { (result, error) in
                        print("inserOrder = \(String(describing: result))")
                    }
                    
                    // 12/15更新 OK
                }
                nowpoint = Int(userPointLabel.text!)! - Int(totalPriceLabel.text!)!
                updateTotalPoint(email: useremail, totalPoints: nowpoint)
                updatequantity = couponquantity! - Int(couponQuantity.text!)!
                updateCouponData(id_coupon: id! + 1, coupon_inventory: updatequantity)
                
                // inserpointdata 消費點數，優惠卷名稱存進資料庫
                self.pointRecords.email = useremail
                self.pointRecords.record_name = couponid! + String(totalQuantityLabel.text!) + "張"
                self.pointRecords.record_points = Int(totalPriceLabel.text!)! * -1
                // 時間戳
                let timeInterval:TimeInterval = TimeInterval(now.timeIntervalSince1970)
                let date = Date(timeIntervalSince1970: timeInterval)
                let dformatter = DateFormatter ()
                dformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                self.pointRecords.record_date = dformatter.string(from: date)
                
                let pointRecordData = try! JSONEncoder().encode(self.pointRecords)
                let pointRecordString = String(data: pointRecordData, encoding: .utf8)
                communicator.inserPoint(pointRecords: pointRecordString!) { (result, error) in
                    print("inserPoint = \(String(describing: result))")
                }
                
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
//            print("Get Image OK.")
            
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
//            print("Get Point OK.")
        }
    }
 
    func isUserValid(email:String, id: Int) {
        communicator.isUserValid(email: email, id: id ) { (result, error) in
            if let error = error {
                print("Get point error:\(error)")
                return
            }
            guard let result = result else {
                print("Data is nil")
                return
            }
            print("result:\(result)")
            
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
//            print("Get Nowquantity OK.")
        }
    }
    
    func updateSumCoupon(email: String, id: Int, sumcoupon: Int) { // 購買user已有優惠卷更新優惠卷數量
        communicator.updateSumCoupon(email: email, id: id, sumcoupon: sumcoupon) { (result, error) in
            if let error = error {
                print("Get updateSumCoupon error:\(error)")
                return
            }

            print("UpdateSumCoupon OK.")
        }
    }
    
    func updateTotalPoint(email: String, totalPoints: Int) { // 買購買成功扣除User點數
        communicator.updateTotalPoint(email: useremail, totalPoint: nowpoint) { (result, error) in
            if let error = error {
                print("Get updateTotalPoint error:\(error)")
                return
            }

        }
    }
    
    func updateCouponData(id_coupon: Int, coupon_inventory: Int) { // 購買後更改商城優惠卷數量
        communicator.updateCouponData(id_coupon: id_coupon, coupon_inventory: coupon_inventory) { (result, error) in
            if let error = error {
                print("Get updateTotalPoint error:\(error)")
                return
            }
        }
    }

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
    
    func inserOrder(shop: String, completion:@escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "insertOrder", "shop": shop]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion:completion)
    }
    
    func updateTotalPoint(email: String, totalPoints: Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "updateTotalPoint",
                                       "email_account": email,
                                       "totalPoints": totalPoints]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
    
    func updateCouponData(id_coupon: Int, coupon_inventory: Int, completion:@escaping DoneHandler) {
        let parameters:[String:Any] = [ACTION_KEY: "updateCouponData",
                                       "id_coupon": id_coupon,
                                       "coupon_inventory": coupon_inventory]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion: completion)
    }
 
    func inserPoint(pointRecords: String ,completion:@escaping DoneHandler){
        
        let parameters:[String:Any] = [ACTION_KEY : "insert", "record": pointRecords]
        doPost(urlString: PointsRecordServlet_URL, parameters: parameters, completion:completion)
    }
}

extension UIView{
    
    func showToast(text: String){
        
        self.hideToast()
        let toastLb = UILabel()
        toastLb.numberOfLines = 0
        toastLb.lineBreakMode = .byWordWrapping
        toastLb.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        toastLb.textColor = UIColor.white
        toastLb.layer.cornerRadius = 10.0
        toastLb.textAlignment = .center
        toastLb.font = UIFont.systemFont(ofSize: 15.0)
        toastLb.text = text
        toastLb.layer.masksToBounds = true
        toastLb.tag = 9999//tag：hideToast實用來判斷要remove哪個label
        
        let maxSize = CGSize(width: self.bounds.width - 40, height: self.bounds.height)
        var expectedSize = toastLb.sizeThatFits(maxSize)
        var lbWidth = maxSize.width
        var lbHeight = maxSize.height
        if maxSize.width >= expectedSize.width{
            lbWidth = expectedSize.width
        }
        if maxSize.height >= expectedSize.height{
            lbHeight = expectedSize.height
        }
        expectedSize = CGSize(width: lbWidth, height: lbHeight)
        toastLb.frame = CGRect(x: ((self.bounds.size.width)/2) - ((expectedSize.width + 20)/2), y: self.bounds.height - expectedSize.height - 60 - 30, width: expectedSize.width + 20, height: expectedSize.height + 20)
        self.addSubview(toastLb)
        
        UIView.animate(withDuration: 1, delay: 1, animations: {
            toastLb.alpha = 0.0
        }) { (complete) in
            toastLb.removeFromSuperview()
        }
    }
    
    func hideToast(){
        for view in self.subviews{
            if view is UILabel , view.tag == 9999{
                view.removeFromSuperview()
            }
        }
    }
}
