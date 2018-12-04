//
//  Running.swift
//  IosBonusRunningBeforeYou
//
//  Created by Janhon on 2018/11/21.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct Running: Codable {
    
    var id: Int = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var mail: String = ""
    var password: String = ""
    var name: String = ""
    var points: Double = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    
    
    
    
//    func getTime() -> CLong {
//        guard let time = time else {
//           return 0
//        }
//        return time
//    }
    
}


struct FirstGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0

}

struct SecondGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0
}

struct ThirdGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0
}

struct FourthGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0
}

struct FifthGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0
}

struct SixthGroupMember: Codable {
    var id: Int = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var distance: Double = 0
    var time: Int = 0
    var totalTime: Double = 0
    var startTime: Int = 0
    var endTime: Int = 0
    var points: Double = 0
}
