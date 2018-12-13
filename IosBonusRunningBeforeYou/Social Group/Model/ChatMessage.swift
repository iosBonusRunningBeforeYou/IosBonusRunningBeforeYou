//
//  ChatMessage.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/12/12.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct ChatMessage:Codable {
    
    var  sender:String
    var  receiver:Int
    var  message:String?
    
}
