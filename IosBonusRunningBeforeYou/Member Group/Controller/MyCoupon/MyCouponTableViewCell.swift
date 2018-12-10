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

}
