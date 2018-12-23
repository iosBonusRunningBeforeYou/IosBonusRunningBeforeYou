//
//  ChatItem.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/12/11.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct ChatData:Codable {
    var  message:String?
    var  emailAccount:String?
    var  lastUpdateDateTime:String?
    var  groupId:Int?
}
