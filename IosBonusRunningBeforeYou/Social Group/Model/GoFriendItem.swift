//
//  GoFriendItem.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/26.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct GoFriendItem:Codable {
    var groupId: Int?
    var emailAccount: String?
    var groupName: String?
    var startPointLatitude: Double?
    var startPointLongitude: Double?
    var endPointLatitude: Double?
    var endPointLongitude: Double?
    var groupRunningTime: String?
//    var newGroupTime:String?
    var groupRunningLastTime: String?
    var lastDay: String?
    var lastHour: String?
    var lastMinute: String?
    var groupJoinPeople: String?
    var groupRunningIntroduce: String?
}
