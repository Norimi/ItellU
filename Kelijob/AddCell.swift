//
//  AddCell.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/19.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class AddCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor.lightGray.cgColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
