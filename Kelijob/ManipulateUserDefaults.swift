//
//  ManipulateUserDefaults.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit

open class ManipulateUserDefaults {

    //id_user, username,facebookのログイン情報など
    static func setConfig(id_user: String, user_name: String, email: String, photoURL: String){
        let defaultObject = UserDefaults.standard
        defaultObject.set(id_user, forKey:"id_user")
        defaultObject.set(user_name, forKey:"name")
        defaultObject.set(email, forKey:"email")
        defaultObject.set(photoURL, forKey:"photoURL")
    }
    
    static func setUserid(id_user:String){
        let defaultObject = UserDefaults.standard
        defaultObject.set(id_user, forKey:"id_user")
    }
    
    static func setEmail(email:String){
        let defaultObject = UserDefaults.standard
        defaultObject.set(email, forKey:"email")
    }
    
    static func setPhotoURL(photoURL:String){
        let defaultObject = UserDefaults.standard
        defaultObject.set(photoURL, forKey:"photoURL")
    }
    
    static func setUsername(user_name:String){
        let defaultObject = UserDefaults.standard
        defaultObject.set(user_name, forKey:"name")
    }
    
    static func setNewestRelationModifiedDate(date:Date) {
        let defaultObject = UserDefaults.standard
        defaultObject.set(date, forKey:"relationModified")
    }
    
    static func setNewestGroupRelationModifiedDate(date:Date) {
        let defaultObject = UserDefaults.standard
        defaultObject.set(date, forKey:"relationGroupModified")
    }
    
    static func setNewestFriendsinGroupsModifiedDate(date:Date) {
        let defaultObject = UserDefaults.standard
        defaultObject.set(date, forKey:"relationFriendsInGroups")
    }
    
    /**
     サインアウト時に呼び出しています。
    */
    static func resetAllNewestModified() {
        let defaultObject = UserDefaults.standard
        defaultObject.removeObject(forKey: "relationModified")
        defaultObject.removeObject(forKey: "relationGroupModified")
        defaultObject.removeObject(forKey: "relationFriendsInGroups")
    }
    
    /**
     現状ここを判定に使用していません
 　*/
    static func setLoggedIn(bool:Bool) {
        let defaultObject = UserDefaults.standard
        defaultObject.set(bool, forKey:"loggedin")
    }
    
    static func setKeliCountForBadge(num:Int) -> Int {
        let defaultObject = UserDefaults.standard
        let nowCount = getKeliCountForBadge() ?? 0
        let newest = nowCount + num
        defaultObject.set(newest, forKey:"countForBadge")
        return newest
    }
    
    static func getKeliCountForBadge() -> Int? {
        let defaultObject = UserDefaults.standard
        let nowCount: Int? = defaultObject.object(forKey: "countForBadge") as! Int?
        return nowCount
    }
    
    static func resetKeliCountForBadge() {
        let defaultObject = UserDefaults.standard
        let resetNum = 0
        defaultObject.set(resetNum, forKey:"countForBadge")
    }
    
    static func setOKEula() {
        let defaultObject = UserDefaults.standard
        defaultObject.set(true, forKey:"eula")
    }
    
    static func removeEula() {
        let defaultObject = UserDefaults.standard
        defaultObject.removeObject(forKey: "eula")
    }
    /**
     実質設定されているかいないかを見ることになるのでOptional
    */
    static func checkEula() -> Bool? {
        let defaultObject = UserDefaults.standard
        let state = defaultObject.object(forKey:"eula") as! Bool?
        return state
    }
    
    static func getUserInfo() -> [String:Any?] {
        return ["id_user":getUserid(), "name":getUsername(), "email":getUserEmail(), "photoURL":getPhotoURL()]
    
    }
    
    static func getUserid() -> String? {
        let defaultObject = UserDefaults.standard
        let tmpUserId = defaultObject.object(forKey:"id_user")
        let returnValue = tmpUserId as? String
        return returnValue 
    }
    
    /**
     - POST通信するためにUserDefaultsから返された値をJSON化して返却するメソッド
 　*/
    static func getUseridOfJSON() -> Data? {
        let uid = ManipulateUserDefaults.getUserid()
        let dic = ["uid":uid]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: dic, options:.prettyPrinted)
            return jsonData
        } catch {
            print("error in JSON Serialization")
        }
        
        return nil
    }
    
    static func getUsername() -> String? {
        let defaultObject = UserDefaults.standard
        let tmpUsername = defaultObject.object(forKey:"name")
        return tmpUsername as! String?
    }
    
    static func getUserEmail() -> String? {
        let defaultObject = UserDefaults.standard
        let tmpUserEmail = defaultObject.object(forKey: "email")
        return tmpUserEmail as! String?
    }
    
    static func getPhotoURL() -> String? {
        let defaultObject = UserDefaults.standard
        let tmpPhotoURL = defaultObject.object(forKey: "photoURL")
        return tmpPhotoURL as! String?
    }
    
    static func equalToUserid(userid:String) -> Bool {
        if(ManipulateUserDefaults.getUserid() == userid){
            return true
        }else {
            return false
        }
    }
    
    //TODO:戻り値のoptionalを削除したい
    static func getNewestRelationModifiedDate() -> Date? {
        let defaultObject = UserDefaults.standard
        let tmpModifiedDate = defaultObject.object(forKey:"relationModified")
        let defaultDate = ConstValue.convertDateFromString("2000-01-01 00:00:00")
        return tmpModifiedDate as? Date ?? defaultDate
    }
    
    static func getNewestGroupRelationModifiedDate() -> Date? {
        let defaultObject = UserDefaults.standard
        let tmpModifiedDate = defaultObject.object(forKey:"relationGroupModified")
        let defaultDate = ConstValue.convertDateFromString("2000-01-01 00:00:00")
        return tmpModifiedDate as? Date ?? defaultDate
    }
    
    static func getNewestFriendsinGroupsModifiedDate() -> Date? {
        let defaultObject = UserDefaults.standard
        let tmpModifiedDate = defaultObject.object(forKey: "relationFriendsInGroups")
        let defaultDate = ConstValue.convertDateFromString("2000-01-01 00:00:00")
        return tmpModifiedDate as? Date ?? defaultDate
    }
    
    static func getLoggedIn() -> Bool {
        let defaultObject = UserDefaults.standard
        let bool = defaultObject.object(forKey: "loggedin") as? Bool
        //デフォルトはfalse
        return bool ?? false
    }
    
    static func deleteUserid() {
        let defaultObject = UserDefaults.standard
        defaultObject.removeObject(forKey: "id_user")
    }
    
    static func deleteUserinfo() {
        let defaultObject = UserDefaults.standard
        defaultObject.removeObject(forKey: "id_user")
        defaultObject.removeObject(forKey: "name")
        defaultObject.removeObject(forKey: "email")
        defaultObject.removeObject(forKey: "profile")
        defaultObject.removeObject(forKey: "photoURL")
        ManipulateUserDefaults.removeEula()
    }
    
    
}
