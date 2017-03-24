//
//  User.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

public class User : Object {

    dynamic var name : String? = nil
    dynamic var id_user : String = ""
    dynamic var email: String = ""
    dynamic var profile : String? = nil
    dynamic var photoURL : String? = nil
    dynamic var created = Date()
    dynamic var modified = Date()
    
    //プライマリキーの設定
    override public static func primaryKey() -> String? {
        return "id_user"
    }
}

public class Friends: Object {
    dynamic var id_user: String = ""
    override public static func primaryKey() -> String? {
        return "id_user"
    }
}

public class FriendsManager {
    
    static func addNewId(_ friend:Friends) {
        let realm = try! Realm()
        do {
            try realm.write{
                realm.add(friend, update:true)
            }
        } catch {
            
        }
    }
    
    static func getAllFriends() -> [String] {
        let realm = try! Realm()
        let friends = realm.objects(User.self)
        let friendsArray = Array(friends)
        var resultArray = [String]()
        for i in 0..<friendsArray.count {
            let thisId = friends[i].id_user
            resultArray.append(thisId)
        }
        return resultArray
    }
    
    static func deleteAllObject(){
        let realm = try! Realm()
        try! realm.write {
            let allItems = realm.objects(Friends.self)
            realm.delete(allItems)
        }
    }
}

public struct ApplyingUser {
    
    let id_user: String
    let name: String
    let email: String?
    let photoURL: String?
    let profile: String?
    let modified: Date?
    let created: Date?
    let id_relation: Int
}


public class UserManager {

    func returningUserId() -> String? {
        return ManipulateUserDefaults.getUserid()
    }
    
    /**
     ## deprecated: getNewestFriendsに一本化
     - 実装時から項目も異なるので使用時はメンテすること
     - リモートからデータをロードしてRealmに入れる
     - 取得しているのは自身のidにひもづけられた友達のidのユーザー情報
     - DB名はFriendなので注意
     - 常にバックグラウンドで使用すること
     */
//    static func downloadUserDataFromRemote(){
//    
//        guard let idJSONData = ManipulateUserDefaults.getUseridOfJSON() else {
//            return
//        }
//        let urlKey = DomainManager.DomainKeys.friendsData
//        let url = DomainManager.readDomainPlist(key: urlKey.rawValue)
//        //通信メソッドで実行されるハンドラ
//        //取得したデータをもとにローカルDBに値をセットする
//        let completionHandler = {(_ data:Data?, _ response:URLResponse?, _ error: Error?) -> Void in
//            
//            do {
//                
//                if(data == nil){
//                    return
//                }
//                
//                let friendsData: Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
//                let newData = friendsData as! Array<Any>
//                
//                for i in 0..<newData.count {
//                    
//                    let thisUser = User()
//                    let newDict:[String:Any] = newData[i] as! [String : Any]
//                    print(newDict)
//                    //nilチェック行いながらRealmオブジェクトを作成してDBへ
//                    if let id_user = newDict["id_user"] {
//                        thisUser.id_user = id_user as! String
//                    }
//                    
//                    if let name = newDict["name"] {
//                        thisUser.name = name as! String
//                    }
//                    
//                    if let email = newDict["email"] {
//                        thisUser.email = email as! String
//                    }
//                    
//                    if let photoURL = newDict["photoURL"] {
//                        thisUser.photoURL = photoURL as! String
//                    }
//                    
//                    if let created = newDict["created"] {
//                        
//                        let format = "YYYY-MM-DD HH:mm:ss"
//                        let formatter = DateFormatter()
//                        formatter.dateFormat = format
//                        if let thisDate = formatter.date(from: created as! String){
//                            thisUser.created = thisDate
//                        }
//                        
//                    }
//                    //RealmにUserを追加する
//                    UserManager.addNewFriends(friend: thisUser)
//                }
//                
//            } catch {
//                print("JSON error occured in downloadUserDataFromRemote(or there is no data)")
//            }
//        }
//        KeliConnection.postMethodWithCompletionHandler(urlString: url, data: idJSONData, completionHandler: completionHandler)
//    
//    }
    
    
    
    /**
     - Userのデータをダウンロードするのは、招待が受け入れられたとき
     - Relationが最新であるかどうかを確認する
     - 確認したときに実行すればよいのでWebSocketは使用しない
     */
    static func downloadNewestFriends() {
        
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        let thisDate = ManipulateUserDefaults.getNewestRelationModifiedDate()         
        let dateString = ConstValue.stringFromDate(date: thisDate!)
        let postDict = ["uid":uid, "modified":dateString]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestFriends.rawValue
            let url = DomainManager.readDomainPlist(key:urlKey)
            
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void in
              
                do {
                    
                    if(data == nil){
                        return
                    }
                    
                    let decodedDeta: Any? = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let resultArray = decodedDeta as! Array<Any>?
                    if(resultArray?[0] is NSNull){
                        return
                    }
                    guard let modifiedDate: String = resultArray?[0] as! String? else {
                        return
                    }
                    let friendArray:Array<Any> = resultArray![1] as! Array<Any>
                    
                    for i in 0..<friendArray.count {
                        let thisUser = User()
                        let newDict:[String:Any] = friendArray[i] as! [String:Any]
                        
                        if let id_user = newDict["id_user"] {
                            thisUser.id_user = id_user as! String
                        }
                        if let name = newDict["name"] {
                            thisUser.name = name as! String
                        }
                        if let email = newDict["email"] {
                            thisUser.email = email as! String
                        }
                        if let photoURL = newDict["photoURL"]{
                            thisUser.photoURL = photoURL as? String
                        }
                        if let profile = newDict["profile"] {
                            thisUser.profile = profile as? String
                        }
                        if let created: String = newDict["created"] as! String? {
                            if let newDate = ConstValue.convertDateFromString(created){
                                thisUser.created = newDate
                            }
                        }
                        if let modified: String = newDict["modified"] as! String? {
                            if let newDate = ConstValue.convertDateFromString(modified){
                                thisUser.modified = newDate
                            }
                        }
                        //ここでidを保存している友達がユーザーの友達
                        //get
                        UserManager.addNewFriends(friend: thisUser)
                        let thisId = thisUser.id_user
                        let thisFr = Friends()
                        thisFr.id_user = thisId
                        FriendsManager.addNewId(thisFr)
                    }
                    
                    //end of completion handler
                    //処理終了後にUserDefaultを更新する
                    let newestModifiedDate = ConstValue.convertDateFromString(modifiedDate)
                    ManipulateUserDefaults.setNewestRelationModifiedDate(date: newestModifiedDate!)
                    
                    
                } catch {
                    
                }
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            print("json error")
        }
        
    }
    
    
    /*
     ## deprecated
     ### このAPIを使用するとするとデータの整合性を保つのが難しいと判断
    */
//    static func getNewestModifiedDate() -> String? {
//        let allUsers = UserManager.getAllFriends()
//        print(allUsers)
//        let newestModifiedUser = allUsers.sorted(byProperty:"modified", ascending: false)
//        if(newestModifiedUser.count == 0){
//            return ""
//        }
//        if let newestDate:Date? = newestModifiedUser[0].modified {
//            print(newestModifiedUser[0].modified)
//            return ConstValue.stringFromDate(date: newestDate!)
//        } else {
//            return ""
//        }
//    }
    
    /**
     友達申請取得API
     SelectFriendViewControllerから呼び出しApplyingFriendを配列としてVCに持たせる
    */
    //completionHandlerはFriendsGroupTableViewControllerから渡される
    static func getFriendApplication(reloadDataHandler:@escaping (Array<ApplyingUser>) -> Void) {
        
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        let postDict = ["id_user":uid]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getApply.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp: URLResponse?, _ err: Error?) -> Void in
               
                guard let friendData = data else{
                   return
                }
                var resultFriendArray = Array<ApplyingUser>()
                do {
                    
                    let decodedData: Any = try JSONSerialization.jsonObject(with: friendData, options: .allowFragments)
                    let friendArray = decodedData as! Array<Any>
                    
                    
                    for i in 0..<friendArray.count {
                        
                        let thisDict:[String:Any] = friendArray[i] as! [String:Any]
                        
                        var tmpUserId: String = ""
                        var tmpName: String = ""
                        var tmpProfile: String = ""
                        var tmpPhotoURL: String = ""
                        var tmpIdRelation: Int = 0
                        
                        if let id_user = thisDict["id_user"] {
                            tmpUserId = id_user as! String
                        }
                        
                        if let name = thisDict["name"] {
                            tmpName = name as! String
                        }
                        
                        if let profile = thisDict["profile"] {
                            tmpProfile = profile as! String
                        }
                        
                        if let photoURL = thisDict["photoURL"] {
                            tmpPhotoURL = photoURL as! String
                        }
                        
                        if let id_relation = thisDict["id_relation"] {
                        
                            tmpIdRelation = Int(id_relation as! String)!
                        }
                        
                        let thisFriend = ApplyingUser(id_user: tmpUserId, name: tmpName, email: nil, photoURL: tmpPhotoURL, profile: tmpProfile, modified: nil, created: nil, id_relation: tmpIdRelation)
                        resultFriendArray.append(thisFriend)
                        
                    }
                    
                } catch {
                    print("JSON error in getFriendApplication completion handler")
                }
                
                //end of completion handler
                //FriendsGroupTableViewControllerから渡される
                reloadDataHandler(resultFriendArray)
            
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)

            
        } catch {
            print("JSON error in getFriendApplication")
        }
    }
    
    /**
     グループのメンバーを問い合わせて結果を配列で返し永続化しない
 　*/
    static func getFriendsFromGroup(id_group:Int, resultHandler:@escaping ([[String:Any]])-> Void) {
        
        guard ManipulateUserDefaults.getUserid() != nil else {
            return
        }
        
        let postDict:[String:Any] = ["id_group":id_group]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getFriendsFromGroup.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
            in
                //常にUIと連動して実施されるので、エラー時にはアラートを表示する
                //使用方法を変えるときは改修する
                
                if let response = resp as! HTTPURLResponse? {
                    let statusCode = response.statusCode
                    if(statusCode != 200){
                        AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                        return
                    }
                    if(err != nil){
                        
                        AlertControllerManager.showAlertController("エラーです", "しばらくしてから\nもういちどお試しください", nil)
                        return
                    }
                    
                }
               
                if(data == nil){
                    return
                }
                var resultFriendsArray = [[String:Any]]()
                do {
                    let jsonFriendData  = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let friendArray = jsonFriendData as! Array<[String:Any]>
                    
                    
                    for i in 0..<friendArray.count {
                        var thisUser = [String:Any]()
                        let newDict:[String:Any] = friendArray[i] 
                        
                        if let id_user = newDict["id_user"] {
                            thisUser["id_user"] = id_user as! String
                        }
                        if let name = newDict["name"] {
                            thisUser["name"] = name as! String
                        }
                        if let email = newDict["email"] {
                            thisUser["email"] = email as! String
                        }
                        if let photoURL = newDict["photoURL"]{
                            thisUser["photoURL"] = photoURL as? String
                        }
                        if let profile = newDict["profile"] {
                            thisUser["profile"] = profile as? String
                        }
                        if let created: String = newDict["created"] as! String? {
    
                            if let newDate = ConstValue.convertDateFromString(created){
                                thisUser["created"] = newDate
                            }
                        }
                        if let modified: String = newDict["modified"] as! String? {
                            if let newDate = ConstValue.convertDateFromString(modified){
                                thisUser["modified"] = newDate
                            }
                        }
            
                        resultFriendsArray.append(thisUser)
                        //クロージャ内からクロージャを呼び出す
                    }
                    
                    
                } catch {
                    
                }
                resultHandler(resultFriendsArray)
            //end of completionHandler
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            
        }
    }

    /**
     ## Friendsに保存しているid_userを検索してユーザーを返す
     - id_userはgetNewestFriends時に挿入
     - 自身を含まない（ログイン時にFriendsには挿入されていない)
　　 */
    static func getAllFriends() -> Results<User> {
        //TODO:FriendsManagerのgetAllFriendsを使用したい!
        let realm = try! Realm()
        let friends = realm.objects(Friends.self)
        var friendsIdArray = [String]()
        for i in 0..<friends.count {
            let thisId = friends[i].id_user
            friendsIdArray.append(thisId)
        }
        let predicate = NSPredicate(format: "id_user IN %@", friendsIdArray)
        let resultFr = realm.objects(User.self).filter(predicate)
        return resultFr
    }
    
    static func queryUserById(id_user:String) -> User? {
        let realm = try! Realm()
        let queriedUser = realm.objects(User.self).filter("id_user = %@",id_user)
        //返される配列がnilの場合、配列外参照になるので
        if(queriedUser.count == 0){
            return User()
        }
        return queriedUser[0]
    }
    
    static func returnNameFromId(id_user:Int) -> String? {
        let realm = try! Realm()
        let queriedObject = realm.objects(User.self).filter("id_user = %@",id_user)
        let result = queriedObject[0]
        return result.name
    }
    
    static func deleteUserFromId(id_user:String?){
        let realm = try! Realm()
        guard id_user != nil else {
            return
        }
        let queriedObject = realm.objects(User.self).filter("id_user = %@",id_user)
        do {
            try realm.write {
                realm.delete(queriedObject)
            }
        } catch {
            print("error")
        }
    }
    
    static func deleteAllObject(){
        let realm = try! Realm()
        try! realm.write {
            let allItems = realm.objects(User.self)
            realm.delete(allItems)
            let str = "2000-01-01 00:00:00"
            let date = ConstValue.convertDateFromString(str)
            ManipulateUserDefaults.setNewestRelationModifiedDate(date: date!)
        }
    }

    static func addNewFriends(friend:User){
        let realm = try! Realm()
        try! realm.write {
            let queriedObject = realm.objects(User.self).filter("id_user = %@",friend.id_user)
            if(queriedObject.count == 0){
                realm.add(friend, update:true)
            }
        }
    }
    
    static func queryJobInProgress(id_user:Int) -> Job? {

        print("id_user %@",id_user)
        
        let reportObjects : Results<Report>? = ReportManager.queryInProgressReportByIdUser(id_user:id_user)
        //TODO：配列の０に最近のものが入っていることを確認する
        if(reportObjects?.count == 0){
            return nil
        }
        guard let thisReport = reportObjects?[0] else {
            return nil
        }
        let thisJobId : Int? = thisReport.id_job
        let thisJob : Results<Job>? = JobManager.queryJobById(id_job: (thisJobId)!)
        return thisJob![0]
    }
    
}

