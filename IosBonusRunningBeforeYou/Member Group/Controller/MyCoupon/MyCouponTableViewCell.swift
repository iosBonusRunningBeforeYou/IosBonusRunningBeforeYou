//
//  MyCouponTableViewCell.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/9.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class MyCouponTableViewCell: UITableViewCell {
    @IBOutlet weak var myCouponTitle: UILabel!
    @IBOutlet weak var myCouponImage: UIImageView!
    @IBOutlet weak var myCouponRemainingAmount: UILabel!
    @IBOutlet weak var myCouponUseBtn: UIButton!
    
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
