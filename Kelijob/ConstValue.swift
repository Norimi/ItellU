//
//  ConstValue.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/11.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class ConstValue: NSObject {
    
    static let globalCellHeight: CGFloat = CGFloat(104)
    
    //xibより先にこちらの値を変更しています。xibとの整合性を保ってください。
    static let globalTimelineCellHeight: CGFloat = CGFloat(380)
    
    //色定義
    //#F38181
    static let globalPink = UIColor(red:0.95, green:0.51, blue:0.51, alpha:1.0)
    //#EAFFD0
    static let globalGreen = UIColor(red:0.92, green:1.00, blue:0.82, alpha:1.0)
    //#95E1D3
    static let globalDeepGreen = UIColor(red:0.58, green:0.88, blue:0.83, alpha:1.0)
    //#FCE38A
    static let globalYellow = UIColor(red:0.99, green:0.89, blue:0.54, alpha:1.0)
    
    
    /**
     strがnilのとき2000年1月1日をかえす
    */
    static func convertDateFromString(_ str:String?) -> Date? {
        
        let format = "YYYY-MM-dd HH:mm:ss"
        let formatter = DateFormatter()
        let calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        formatter.timeZone = NSTimeZone.default
        formatter.calendar = calendar 
        if let dateString = str {
            return formatter.date(from: dateString)
        } else {
            return formatter.date(from: "2000-01-01 00:00:00")
        }
    }
    
    static func stringFromDate(date: Date?) -> String {
  
        guard let argDate:Date = date else {
            return "2000-01-01 00:00:00"
        }
        let formatter: DateFormatter = DateFormatter()
        let format = "YYYY-MM-dd HH:mm:ss"
        formatter.dateFormat = format
        return formatter.string(from: argDate)
    }
}

/**
 ## Viewのスタイルの定義
 - awakeFromNib()に実装した内容はxibファイルの実装を上書きします。
 */
//カスタムセルのボーダーと選択時のスタイルを定義
extension UITableViewCell {
    
    override open func draw(_ rect: CGRect) {
        // Drawing code
        super.draw(rect)
        self.layer.borderWidth = 0.25
        self.layer.borderColor = UIColor.gray.cgColor
        self.selectionStyle = .none
        self.textLabel?.font = UIFont(name: "Hiragino Sans W6", size: 13)
        self.detailTextLabel?.font = UIFont(name: "Hiragino Sans W3", size:8)
        self.detailTextLabel?.textColor = UIColor.darkGray
    }
    
}

extension UITableView {
    override open func draw(_ rect: CGRect){
        self.separatorColor = UIColor.gray
        self.separatorStyle = .none
    }
}

extension UITextField {
    override open func awakeFromNib() {
        self.backgroundColor = UIColor.white
        self.layer.borderColor = UIColor.gray.cgColor
        self.layer.borderWidth = 0.5
        self.clipsToBounds = true
        self.isOpaque = false
    }
    
}

extension UINavigationBar {
    override open func awakeFromNib() {
        let navigationFont = UIFont(name: "Hiragino Sans W6", size: 15)
        self.titleTextAttributes = [NSFontAttributeName:navigationFont]
    }
}

extension UIBarButtonItem {
    override open func awakeFromNib() {
        let navigationFont = UIFont(name: "Hiragino Sans W6", size: 15)
        let attrDict = [NSFontAttributeName: navigationFont]
        self.setTitleTextAttributes(attrDict, for: .normal)
        self.setTitleTextAttributes(attrDict, for: .highlighted)
        self.setTitleTextAttributes(attrDict, for: .focused)
        self.setTitleTextAttributes(attrDict, for: .selected)

    }
}

extension UIButton {
    override open func awakeFromNib() {
        self.titleLabel?.font =  UIFont(name: "Hiragino Sans W6", size: 17)
        self.isExclusiveTouch = true
    }
}

extension UITabBar {
    override open func awakeFromNib() {
        
        self.tintColor = ConstValue.globalPink
        self.barTintColor = ConstValue.globalDeepGreen
        self.barTintColor = ConstValue.globalDeepGreen
        
        self.items?[0].image = UIImage(named: "World_Times@2x.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.items?[1].image = UIImage(named: "Contact@2x.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        self.items?[2].image = UIImage(named: "Smartphone_Outgoing@2x.png")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        
        self.items?[0].selectedImage = UIImage(named: "World_Times@2x.png")
        self.items?[1].selectedImage = UIImage(named: "Contact@2x.png")
        self.items?[2].selectedImage = UIImage(named: "Smartphone_Outgoing@2x.png")
    }
    
}

extension String {
    var length: Int {
        return self.characters.count
    }
}

