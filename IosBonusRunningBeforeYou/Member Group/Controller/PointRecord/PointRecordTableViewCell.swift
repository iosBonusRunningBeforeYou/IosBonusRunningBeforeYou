//
//  PointRecordTableViewCell.swift
//  IosBonusRunningBeforeYou
//
//  Created by Edward on 2018/12/7.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
 
class PointRecordTableViewCell: UITableViewCell {
    
    @IBOutlet weak var recordNameLabel: UILabel!
    @IBOutlet weak var recordPointsLabel: UILabel!
    @IBOutlet weak var recordDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
