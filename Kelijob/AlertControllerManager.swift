//
//  AlertViewControllerManager.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/23.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class AlertControllerManager: NSObject {
    
    static func getTopMostViewController()->UIViewController {
        var tc = UIApplication.shared.keyWindow?.rootViewController;
        while ((tc!.presentedViewController) != nil) {
            tc = tc!.presentedViewController;
        }
        return tc!;
    }
    
    static func showAlertController(_ title:String, _ message:String, _ completion:(() -> Swift.Void)?) {

        DispatchQueue.main.async {
            let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
            let topVC = AlertControllerManager.getTopMostViewController()
            topVC.present(alertVC, animated: true, completion: completion)
            
            let sel = #selector(AlertControllerManager.removeAlertController(timer:))
            let userInfo = alertVC
            let tm = Timer.scheduledTimer(timeInterval: 10, target: AlertControllerManager.self, selector: sel, userInfo: userInfo, repeats: false)
            tm.fire()
        }
    }
    
    static func showAlertControllerWithoutTimer(_ title:String, _ message:String, _ completionHandler:((UIAlertController) -> Swift.Void)?){
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let topVC = AlertControllerManager.getTopMostViewController()
        topVC.present(alertVC, animated: true, completion: nil)
        completionHandler!(alertVC)
    }
    
    static func removeAlertController(timer:Timer!) {
        let alertVC = timer.userInfo as! UIAlertController
        alertVC.dismiss(animated:true, completion:nil)
    }

}
