//
//  UIBorderedTextView.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/21.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class UIBorderedTextView: UITextView {

    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
    }
    
    override func awakeFromNib() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.5
        //self.layer.cornerRadius = 5
        self.clipsToBounds = true
        self.isOpaque = false
    }
   

}

//extension UIButton {
//    
//    override open var isHighlighted: Bool {
//        didSet {
//            switch isHighlighted {
//            case true:
//                backgroundColor = UIColor.white
//            case false:
//                backgroundColor = UIColor.white
//            }
//        }
//    }
//    
//}
