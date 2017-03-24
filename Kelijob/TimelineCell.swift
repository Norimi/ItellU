//
//  TimelineCell.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/17.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit

class TimelineCell: UITableViewCell {
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!    
    @IBOutlet weak var jobImageView: UIImageView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var selectFriendBtn: UIButton!
    @IBOutlet weak var dateLabel: UILabel!

    @IBOutlet weak var debug_id_KeliLabel: UILabel!
    @IBOutlet weak var jobView: UIView!
    @IBOutlet weak var selectGroupBtn: UIButton!
    @IBOutlet weak var creatorLabel: UILabel!
    
    @IBOutlet weak var commentBackgroundView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.jobView.layer.borderColor = UIColor.gray.cgColor
        self.jobView.layer.borderWidth = 0.5
        //self.jobView.layer.cornerRadius = 5
        self.jobView.clipsToBounds = true
        self.jobView.isOpaque = false
        
        // Initialization code
        self.commentBackgroundView.layer.borderColor = UIColor.gray.cgColor
        self.commentBackgroundView.layer.borderWidth = 0.5
        //self.jobView.layer.cornerRadius = 5
        self.commentBackgroundView.clipsToBounds = true
        self.commentBackgroundView.isOpaque = false
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
