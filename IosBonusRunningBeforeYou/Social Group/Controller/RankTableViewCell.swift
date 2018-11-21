//
//  RankTableViewCell.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/11/20.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class RankTableViewCell: UITableViewCell {

    @IBOutlet weak var rankNumLabel: UILabel!
    @IBOutlet weak var rankImageView: UIImageView!
    @IBOutlet weak var rankOfUserNameLabel: UILabel!
    @IBOutlet weak var rankOfRuleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
