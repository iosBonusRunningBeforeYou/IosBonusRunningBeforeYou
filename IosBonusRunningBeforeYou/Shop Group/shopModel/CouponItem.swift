//
//  CouponItem.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/11/29.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct CouponItem: Codable {
    
    var id: Int
    var couponid: String  // 優惠卷名稱
    var quantity: Int  // 數量
    var price: Int  //價格
    var expiredate: String  // 有效日期
    var image: Int
    
}

struct Order: Codable {
    
    var useremail: String = ""
    var id: Int = 0
    var totalquantity: Int = 0
    
}

struct PointsRecord: Codable {
    var record_name: String = ""
    var record_points: Int = 0
    var record_date: String = ""
    var email: String = ""
}
