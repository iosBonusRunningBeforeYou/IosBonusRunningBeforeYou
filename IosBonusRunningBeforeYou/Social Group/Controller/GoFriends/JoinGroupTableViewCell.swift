//
//  JoinGroupTableViewCell.swift
//  IosBonusRunningBeforeYou
//
//  Created by Apple on 2018/12/4.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit

class JoinGroupTableViewCell: UITableViewCell {
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var joinPeopleLabel: UILabel!
    @IBOutlet weak var lastTimeLabel: UILabel!
    @IBOutlet weak var nunJoinCellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
