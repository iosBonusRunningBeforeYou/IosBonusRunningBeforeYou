//
//  TempUserData.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/11/21.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

// 假的user 等待會員更新資料後, 再將此物件取消
struct TempUserData : Codable {
    
    var email_account: String = ""
    var password: String = ""
    var name: String = ""
    var gender: Int = 0
    var age: Int = 0
    var height: Int = 0
    var weight: Float = 0
    var totalPoint: Int = 0
    var target_daily: Double = 0
    var target_weekly: Double = 0
    var target_monthly: Double = 0
}


