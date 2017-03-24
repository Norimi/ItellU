//
//  ErrorManager.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/07.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

/**
 エラー定義集
 */
class ErrorManager: NSObject {
    
    enum ConnectionFailed: Error {
        case timeout
        case cannotConnect
    }

}
