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

}
