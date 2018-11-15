//
//  GameItem.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/14.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct GameItem:Codable {
     var emailAccount:String
     var gameId:Int
     var gameName:String
     var gameDetail:String
     var gamePreface:String
     var lastDay:String
     var lastHour:String
     var lastMinute:String
     var gameJoinPeople:String
     var ruleId:Int
}
