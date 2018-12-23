//
//  ShopTableViewCell.swift
//  IosBonusRunningBeforeYou
//
//  Created by Marines Chin on 2018/11/30.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class ShopTableViewCell: UITableViewCell {

    @IBOutlet weak var CouponidLable: UILabel!
    @IBOutlet weak var QuantityLable: UILabel!
    @IBOutlet weak var ExpiredateLable: UILabel!
    @IBOutlet weak var PriceLable: UILabel!
    @IBOutlet weak var CouponImage: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame =  newFrame
            frame.origin.x += 5
            frame.origin.y += 5 // sesection 間的間距
            frame.size.height -= 1 * 5 // cell 間的高度
            frame.size.width -= 1 * frame.origin.x // cell 左邊距
            frame.size.width -= 1 * 5 // cell 右邊距
            super.frame = frame
        }
    }

}
