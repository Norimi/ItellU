//
//  DomainManager.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/04.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class DomainManager: NSObject {
    
    enum DomainKeys: String{
        
        case setUserInfo = "setUserInfo"
        case confirmUserid = "confirmUserid"
        case createJob = "createJob"
        case createReport = "createReport"
        case friendsData = "friendsData"
        case createKeli = "createKeli"
        case getAllKelis = "getAllKelis"
        case getAllJobs = "getAllJobs"
        case getAllReports = "getAllReports"
        case searchFriend = "searchFriend"
        case getNewestJobs = "getNewestJobs"
        case getNewestKelis = "getNewestKelis"
        case getNewestReports = "getNewestReports"
        case createRelation = "createRelation"
        case applyFriend = "applyFriend"
        case getApply = "getApply"
        case acceptApplication = "acceptApplication"
        case getNewestFriends = "getNewestFriends"
        case createGroup = "createGroup"
        case getNewestGroup = "getNewestGroup"
        case getFriendsFromGroup = "getFriendsFromGroup"
        case getJobsByReceiver = "getJobsByReceiver"
        //remoteから取得する仕様に変更したので未使用
        case getAllFriendsGroups = "getAllFriendsGroups"
        case deleteRelation = "deleteRelation"
        case friendImagePlaceholder = "http://placehold.jp/85x85.png?text=Kelijob"
        case profileImagePlaceholder = "http://placehold.jp/150x150.png?text=Kelijob"
        case getUser = "getUser"
        case insertToken = "insertToken"
        case reportObjectionable = "reportObjectionable"
    }
    
    //enumの値からキーを検索してplistのdomainを返す
    static func readDomainPlist(key:String) -> String {
        
        //本番環境のときplistファイル名を変更する
        //TODO:一時的にデバッグ環境でもremoteを使用する
        #if DEBUG
            let bundle = Bundle.main.path(forResource: "remote_stg_domains", ofType: "plist")
        #else
            let bundle = Bundle.main.path(forResource: "remote_release_domains", ofType: "plist")
        #endif
        let dict = NSDictionary(contentsOfFile: bundle!)
        let valueString = dict?[key]
        return valueString as! String    
    }

}
