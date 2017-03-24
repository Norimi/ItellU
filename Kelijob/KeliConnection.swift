//
//  KeliConnection.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/16.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import FirebaseAuth

class KeliConnection: NSObject {
    
    /**
     ## リモートから最新データを取得してRealmに格納する
     - AppDelegateからタイマーを使用して定期的に実行する
     */
    static func downloadNewestDataInInterval(){
        

        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
                DispatchQueue(label: "jp.flatlevel.app.queue").async {
                    //https://developer.apple.com/legacy/library/documentation/Darwin/Reference/ManPages/man3/sleep.3.html
                    sleep(1)
                    JobManager.downloadNewestJobs()
                    sleep(1)
                    KeliManager.downloadNewestKelis()
                    sleep(1)
                    ReportManager.downloadNewestReports()
                    sleep(1)
                    UserManager.downloadNewestFriends()
                    sleep(1)
                    GroupManager.downloadNewestGroups()
                    //友達申請も常時確認してプロフィールに表示/バッジ表示/ワンタッチで受諾できるようにする
                    print("inserting data in sub thread (if there is)...")
                }
                
            } else {
                //サインインしていない
                //TODO:現状抜けるだけだが、ログイン処理させたい！
                //どうしたらAuthUIをどこからでも表示できるでしょうか
                //明示的にサインアウトさせてログイン表示させる？
            }
        }
        
    }
    
    /**
     URLSessionを使用してPOSTメソッドで通信する汎用メソッド
     - DomainManagerの列挙子を使用してdomainのキーを指定します
     */
    static func postMethod(urlString:String, data:Data){
        
        let url = URL(string: urlString)
        
        //デバッグ用
        let str: String! = String(data: data, encoding: .utf8)
        print("data in postMethod / url",str, urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        let sessionTask = urlSession.dataTask(with: request, completionHandler: {data,resp,err
            in print("")})
        sessionTask.resume()
        urlSession.finishTasksAndInvalidate()

    }
    
    /**
     ## 通信終了時のCompletion Handlerを引数としてとりながら通信を実行する
     - エラーを投げるクロージャのエラーを補足できる関数として実装
     - completionHandlerをキャプチャするのでescapingとみなされる
     */
    static func postMethodWithCompletionHandler(urlString:String, data:Data, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) {
        
        
        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
            } else {
                //サインインしていない
                return
            }
        }
        
        let str: String! = String(data: data, encoding: .utf8)
        print("data in postMethod / url",str, urlString)
        let url = URL(string: urlString)
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        let config = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: config)
        let sessionTask = urlSession.dataTask(with: request, completionHandler: completionHandler)
        sessionTask.resume()
        //これ以上新しいtaskを作成せず現在のtaskが終了するのを待ってinvalidateする
        urlSession.finishTasksAndInvalidate()
        
    }
    
    
    #if DEBUG
    /**
     XCTestで実行不可能なため実装されたテストコード
     */
    static func testCreateUsersInRemoteDB(){
        
        for i in 0..<30 {
            
            let uid = String(i)
            let name = String(i)+"美"
            let profile = String(i) + "番目の登録者"
            let email = String(i) + "@gmail.com"
            let photoURL = String(i)
            let userDict : [String:Any?] = ["uid":uid, "name":name, "email":email, "photoURL":photoURL]
            
            do{
                
                let jsonData = try JSONSerialization.data(withJSONObject:userDict, options:.prettyPrinted)
                let urlKey = DomainManager.DomainKeys.setUserInfo
                let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
                KeliConnection.postMethod(urlString:url, data:jsonData)
                
            } catch {
                
                print("error in JSONSerialization")
            }
        }
    }
    #endif
    
    
}
