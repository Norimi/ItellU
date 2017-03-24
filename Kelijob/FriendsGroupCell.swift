//
//  FriendsGroupCell.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/17.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit

class FriendsGroupCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var jobInProgressLabel: UILabel!
    @IBOutlet weak var fbImageView: UIImageView!
    @IBOutlet weak var applyBtn: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        self.layer.borderWidth = 0.25
//        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
