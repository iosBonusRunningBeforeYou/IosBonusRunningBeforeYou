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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        getCouponList()

    }
    
//    @IBAction func detailBtn(_ sender: AnyObject) {
//        let buttonPosition:CGPoint = sender.convert(CGPoint.zero, to:self.tableView)
//        let indexPath = self.tableView.indexPathForRow(at: buttonPosition)
//        print(indexPath)

//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as? ExchangeViewController
       
        
        if let row = tableView.indexPathForSelectedRow?.row {
            controller?.couponid = couponItem[row].couponid
            controller?.expiredate = couponItem[row].expiredate
            controller?.totalprice = String(couponItem[row].price)
            controller?.couponquantity = couponItem[row].quantity
            controller?.id = row
        }
            
    }
    
    // MARK: - Table View delegate methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return couponItem.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200 // 設定cell高度
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 3 // 間距高度
//    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:ShopTableViewCell = self.tableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier) as! ShopTableViewCell
        
        let coupon = self.couponItem[indexPath.row]
        
        cell.CouponidLable.text = "\(coupon.couponid)"
        cell.QuantityLable.text = "剩餘數量：\(coupon.quantity)"
        cell.ExpiredateLable.text = "\(coupon.expiredate)"
        cell.PriceLable.text = "\(coupon.price)"
        getCouponImage(cell.CouponImage, coupon.id)
        
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
                self.couponItem.append(coupon)
            }
            self.tableView.reloadData()
            
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

extension Communicator {
    
    func getCouponImage(url:String ,id:Int , imageSize:Int = 1024, completion:@escaping DownloadDoneHandler ){
        let paramters:[String:Any] = [ACTION_KEY : GET_IMAGE_KEY,
                                      "id" : id,
                                      IMAGE_SIZE_KEY : imageSize]
        
        doPostForImage(urlString: url, parameters: paramters, completion: completion)
    }
}
