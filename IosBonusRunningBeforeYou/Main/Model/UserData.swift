//
//  UserData.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/6.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct UserData : Codable {
    
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
