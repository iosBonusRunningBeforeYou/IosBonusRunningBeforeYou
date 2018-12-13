//
//  UserItem.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/12/13.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct UserItem: Codable {
    var email_account: String
    var age: Int
    var gender: Int
    var height: Int
    var name: String
    var password: String
    var target_daily: Double
    var target_monthly: Double
    var target_weekly: Double
    var totalPoint: Int
    var weight: Float
}
