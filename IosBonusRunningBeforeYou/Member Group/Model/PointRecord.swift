//
//  PointRecord.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/7.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation

struct PointRecord: Codable {

    var record_name: String = ""
    var record_points: Int = 0
    var record_date: String = ""
    var email: String = ""
}
