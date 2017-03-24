//
//  ReportCell.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/22.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class ReportCell: UITableViewCell {

    @IBOutlet weak var reportLabel: UILabel!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var noLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
