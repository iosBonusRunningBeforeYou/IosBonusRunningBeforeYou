//
//  shopViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/11/26.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ShopViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!

    
    // Don't forget to enter this in IB also
    let cellReuseIdentifier = "ShopCell"
    
    let communicator = Communicator.shared
    
    var couponItem = [CouponItem]()
    var couponImage = UIImage()
    var couponIdArray = Array<Int>()
    var sum = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        getCouponList()
        
        for i in couponIdArray.count ... 4 {
            sum = i + 1
            getCouponImage()
        }
       
//        getCouponImage()

    }
    
    @IBAction func detailBtn(_ sender: AnyObject) {
//        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
//        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
//        print(indexPath)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ExchangeViewController
        
        if let row = tableView.indexPathForSelectedRow?.row {
            controller?.couponid = couponItem[row].couponid
            controller?.expiredate = couponItem[row].expiredate
            controller?.totalprice = String(couponItem[row].price)
            
        }
            
    }
    
    // MARK: - Table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponItem.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // 設定cell高度
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 3 // 間距高度
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ShopTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ShopTableViewCell
        
        let coupon = self.couponItem[indexPath.row]
//        let image = self.couponIdArray[indexPath.row]
        
        cell.CouponidLable.text = "\(coupon.couponid)"
        cell.QuantityLable.text = "剩餘數量：\(coupon.quantity)"
        cell.ExpiredateLable.text = "\(coupon.expiredate)"
        cell.PriceLable.text = "\(coupon.price)"
        
//        cell.CouponImage.image? = UIImage(data: couponImage) ?? UIImage(named: "dollar")!
        
        return cell
    }
    
    func getCouponList() {
        communicator.getAll(url: communicator.ShopServlet_URL) { (result, error) in
            if let error = error {
                print("Get all error:\(error)")
                return
            }
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get all  OK")
            
            guard let jsonDate = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted)else {
                print("Fail to generate jsonData.")
                return
            }
            
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([CouponItem].self, from: jsonDate) else {
                print("Fail to decode jsonData.")
                return
            }
            
            for coupon in resultObject {
                self.couponIdArray.append(coupon.id)
                self.couponItem.append(coupon)
            }
            self.tableView.reloadData()
            
            for item in self.couponIdArray  {
                print("self.couponItem:\(item)")
            }
        }
    }
    
    func getCouponImage() {
        
        communicator.getCouponImage(url: communicator.ShopServlet_URL, id: self.sum) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            print("Get Image OK.")
            
            self.couponImage = UIImage(data: data) ?? UIImage(named: "dollar")!
            
            print("json = \(data)")
            self.tableView.reloadData()
        }
    }
    
}
