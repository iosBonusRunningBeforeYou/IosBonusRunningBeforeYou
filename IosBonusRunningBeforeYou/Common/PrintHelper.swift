//
//  PrintHelper.swift
//  DrinkShopClient_IOS
//
//  Created by Mrosstro on 2018/11/14.
//  Copyright © 2018 Nick Wen. All rights reserved.
//

// 範例
// 在 class 內建立 全域變數 TAG
// static let TAG = "ProductPageViewController"
// PrintHelper.println(tag: TAG, line: #line, "MAG")

// 輸出結果
// 在 ProductPageViewController 的 50 行,
// 訊息：MAG

import Foundation

final class PrintHelper {
    static func println(tag: String, line: Int, _ msg: String) {
        print("在 \(tag) 的 \(line) 行,\n訊息：\(msg)\n")
    }
}
