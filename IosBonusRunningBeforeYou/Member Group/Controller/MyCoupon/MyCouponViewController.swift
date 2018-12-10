//
//  MyCouponViewController.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MyCouponViewController: UIViewController {
    
    @IBOutlet weak var myCouponTableView: UITableView!
    
    let userDefaults = UserDefaults.standard
    let communicator = Communicator.shared
    var myCoupons = [MyCoupon]()
    var email = String()
    var couponName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        email = userDefaults.string(forKey: "email")!
        myCouponTableView.delegate = self
        myCouponTableView.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        showAllCoupons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myCoupons.removeAll()
    }
    
    func showAllCoupons() {
        
        communicator.getAllCoupons(email: email) { (result, error) in
            
            if let error = error {
                print("Get Coupons error: \(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get Coupons OK")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted) else {
                print("Fail to generate jsonData.")
                return
            }
            let decoder = JSONDecoder()
            guard let resultObject = try? decoder.decode([MyCoupon].self, from: jsonData) else
            {
                print("Fail to decode jsonData.")
                return
            }
            
            for myCoupon in resultObject {
                if (myCoupon.amount > 0) {
                    self.myCoupons.append(myCoupon)
                }
            }
            
            self.myCouponTableView.reloadData()
            
        }
        
    }

}

//MARK: - UITableViewDataSource
extension MyCouponViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("myCoupons count: \(myCoupons.count)")
        return myCoupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCouponCell", for: indexPath) as! MyCouponTableViewCell
        let item = myCoupons[indexPath.row]
        
        cell.myCouponRemainingAmount.text = String(item.amount)
        communicator.getCouponName(id: item.coupon_id) { (result, error) in
            
            if let error = error {
                print("Get CouponName error: \(error)")
                return
            }
            
            guard let result = result else {
                print("result is nil")
                return
            }
            print("Get CouponName OK")
            
            cell.myCouponTitle.text = (result as! String)
            
        }
        communicator.getCouponImage(url: communicator.ShopServlet_URL, id: item.coupon_id) { (data, error) in
            if let error = error {
                print("Get image error:\(error)")
                return
            }
            guard let data = data else {
                print("Data is nil")
                return
            }
            print("Get Image OK.")
            
            cell.myCouponImage.image = UIImage(data: data)
        }
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension MyCouponViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension Communicator {
    
    func getAllCoupons(email: String, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "getMyCoupons","email": email]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion:completion)
    }
    
    func getCouponName(id: Int, completion: @escaping DoneHandler) {
        
        let parameters:[String:Any] = [ACTION_KEY : "getCouponName","id": id]
        doPost(urlString: ShopServlet_URL, parameters: parameters, completion:completion)
    }
    
}
