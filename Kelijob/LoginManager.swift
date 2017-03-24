//
//  FirebaseLoginManager.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/24.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit
import FirebaseAuth

/**
 ## サインイン、DBとNSUSerDefaultにデータ格納
 - 会員登録にはFirebase Authを使用。
 - Firebase AuthではFacebookログインに対応。
 - プロフィール画像やemailのデータをFacebookから流用。自前サーバーに入れる。
 - 自前サーバーのidはFirebase Authのidを使用。
 - 会員登録とログイン終了後にid登録があるかどうかを確認して、なければ自前サーバーにデータをPOST。
 - 同時にNSUserDefaultsに値を格納。
 - 以後NSUserDefaultsのデータを正式なものとして使用。

 */

class LoginManager: NSObject {
    
    static func signOut(){
        let authUI = FUIAuth.defaultAuthUI()
        
        do {
            
            try authUI?.signOut()
            ManipulateUserDefaults.setLoggedIn(bool: false)
            let id_user = ManipulateUserDefaults.getUserid()
            UserManager.deleteUserFromId(id_user: id_user)
            ManipulateUserDefaults.deleteUserinfo()
            RealmManager.deleteAllData()
            ManipulateUserDefaults.resetAllNewestModified()

            
        } catch {
            print("サインアウト失敗")
            ManipulateUserDefaults.setLoggedIn(bool: true)
        }
    }
    
    
    /**
     ## Auth認証終了後にFB認証とFirebase認証からデータを取得し、独自サーバーとUser Defaultsに格納する
     - parseUserInfo() は認証終了時に呼び出され、FBとこのアプリの認証から情報を取得する
     - confirmUidで取得されたidが独自サーバーに登録されているかチェックする
     - processAfterConfirmUidで、独自サーバーに登録がないときのみ情報を登録する
     - 認証終了時に作成されたデータは、成形されて最後のメソッドまでパスされる
     */
    static func parseUserInfo() {
        
        //uidは、FB認証時にはFBのIDが入り、Firebase認証時にはFirebaseのIDが入ってきます。
        
        //下記userDataの有無でログインしたかどうかを見分けます(直前のdelegate methodでは判断しない/できない)。
        guard let userData = FIRAuth.auth()?.currentUser else {
            //UIをキャンセルしたとき（ログインしていない)
            ManipulateUserDefaults.setLoggedIn(bool: false)
            return
        }
        ManipulateUserDefaults.setLoggedIn(bool: true)
        
        var name: String = ""
        var uid: String = ""
        var email:String = ""
        var photoURL:String = ""
        
        
        for profile in (userData.providerData) {
            
            if(profile.providerID == "facebook.com"){
                
                //FBが提供するidは使用しない
                name = profile.displayName ?? ""
                email = profile.email ?? ""
                photoURL = profile.photoURL?.absoluteString ?? ""
                
            }
            
            //このアプリ独自の認証情報
            //FB認証のデータがない場合に名前とemailを取得する
            if(name == ""){
                name = (userData.displayName) ?? ""
            }
            if(email == ""){
                email = (userData.email) ?? ""
            }
            //FBがあるときでもこのuid(Firebaseのuid)を使用する
            uid = (userData.uid)
        }
        //Apple審査用:ダミーアカウント用にFBからでないphotoURLを入れる
        if(uid == "gASWN6RZjLTbyN7ktDDANnN5LZq2"){
            photoURL = "http://noriming2017.xsrv.jp/Kelijob/test_profile/12.jpg"
        }
        //user dataを作成
        let userDict : [String:Any?] = ["uid":uid, "name":name, "email":email, "photoURL":photoURL]
        
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject:userDict, options:.prettyPrinted)
            //id登録がないかサーバーを確認する。存在していたら抜ける
            //TODO:通信エラー処理
            LoginManager.confirmUid(uid:uid, userinfo:jsonData)
            
        } catch {
            
            print("error in JSONSerialization")
        }
    }
    
    /**
     ユーザーデータを独自サーバーに格納したあとでcompletion handlerから呼び出されるメソッド
     使いたい場合は適宜メソッド名を変更すること
     やりたいことが特になければ削除してもいい
     */
    static func testSelector(){
        //ここはユーザーデータを
        print("test selector")
    }

    /**
     指定されたidが独自サーバーに登録済みかどうかを確認します。
    */
    static func confirmUid(uid:String, userinfo:Data){
        
        let idData = ["uid":uid]
        
        do{
            
            let jsonData = try JSONSerialization.data(withJSONObject: idData, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.confirmUserid.rawValue
            let completionHandler = {(_ data:Data?, _ response:URLResponse?, _ err:Error?) -> Void in
                let response = response as! HTTPURLResponse?
                let statusCode = response?.statusCode
                //ユーザーには特に知らせない

                perform(#selector(LoginManager.processAfterConfirmUid), with: response, with:userinfo)
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString:DomainManager.readDomainPlist(key: urlKey), data:jsonData, completionHandler: completionHandler)
            
            
        } catch {
            print("error in JSON serialization")
        }
    }
    
    
    
    /**
     ログイン終了とみなす
     通信してresponseデータ取得後の処理を行います。
    */
    static func processAfterConfirmUid(_ response:URLResponse?, _ userinfo:Data){
        
        //id_userを確認するAPIを経由して
        //通信完了ハンドラから渡ってきたresponse, userinfoを解析する
        //User DefaultsとRealmに格納/更新する
        do{
            let userData = try JSONSerialization.jsonObject(with: userinfo, options: .allowFragments) as? [String:Any]
            let uid = userData?["uid"] as? String ?? ""
            let name = userData?["name"] as? String ?? ""
            let email = userData?["email"] as? String ?? ""
            let photoURL = userData?["photoURL"] as? String ?? ""
            
            ManipulateUserDefaults.setConfig(id_user: uid, user_name: name, email: email, photoURL: photoURL)
            
            let selfUser = User()
            selfUser.id_user = uid
            selfUser.name = name
            selfUser.email = email
            selfUser.photoURL = photoURL
          
            //自分のデータを保持する
            print("selfUser", selfUser)
            UserManager.addNewFriends(friend: selfUser)
            //全ての関連データをロードする
            DispatchQueue.global().async{
                KeliConnection.downloadNewestDataInInterval()
                DispatchQueue.main.async {
                    //AlertControllerManager.showAlertController("Loading", "データをロードしています", nil)
                    return
                }
                
            }
        } catch {
            print("error in processAfterConfirmUid");
        }
        
        
        let httpRes: HTTPURLResponse? = response as! HTTPURLResponse?
        print(httpRes?.statusCode)
        
        if(httpRes?.statusCode == 212){
        
            //ユーザーidの登録がない、期待どおりの結果の場合
          
            //通信してサーバーに格納する
            //ハンドラの準備
            let completionHandler = {(_ data:Data?, _ url:URLResponse?, _ err:Error?) -> Void in
                //通信終了後に実行される
                perform(#selector(LoginManager.testSelector))
            }
            
            do {
                
                let urlKey = DomainManager.DomainKeys.setUserInfo.rawValue
                KeliConnection.postMethodWithCompletionHandler(urlString:DomainManager.readDomainPlist(key:urlKey), data: userinfo, completionHandler:completionHandler)
                
            } catch {
                
                fatalError("failed in setUserInfo")
            }
            
        } else {
            //サーバーに登録済みの場合
            //ユーザーデフォルトのみ追加/更新してサーバー側の操作はしない
            //サーバーに登録があるがUserDefaultには未登録の場合があるため
            return
        }
        
    }
    
}

