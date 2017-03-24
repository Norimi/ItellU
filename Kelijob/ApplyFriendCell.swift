//
//  ApplyFriendCell.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/17.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class ApplyFriendCell: UITableViewCell {
    
    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!
    @IBOutlet weak var othersLabel: UILabel!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
