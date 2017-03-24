//
//  Keli.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

public class Keli : Object {
    
    dynamic var id_keli : Int = 0
    dynamic var id_job : Int = 0
    dynamic var keli_from_userid : String = ""
    dynamic var keli_to_userid : String = ""
    dynamic var keli_to_groupid: Int = 0
    dynamic var id_keli_before: Int = 0
    dynamic var created = Date()
    dynamic var modified = Date()
    dynamic var accepted : Bool = false
    
    override public static func primaryKey() -> String? {
        return "id_keli"
    }
   
}

public class KeliManager: NSObject, URLSessionDelegate, URLSessionDataDelegate {
    
    /**
     ##リモートからデータをロードしてRealmに入れる
     - Remote:所属するGroupに紐づくJobのKeli 
       - 所属するGroupの配列からさらに配列を取得する
     - Remote:いちどでも蹴ったことのある(keli_from)Jobの全Keli(Keliからid_jobを抽出)
     - Remote:receiver_id_userが自分のJobに紐づく全Keli
     - すべての検索結果を合わせてmodified順に並べる
     */    
    static func downloadNewestKelis(){
        
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        guard let newestModified = KeliManager.getNewestModifiedDate() else {
            return
        }
        let postDict = ["uid":uid,"modified":newestModified]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestKelis
            let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
            let completionHandler = {(_ data: Data?, _resp: URLResponse?, _error: Error?) -> Void in
                
                do {
                    
                    guard let remoteData = data else{
                        return
                    }
                    
                    let newData: Any = try JSONSerialization.jsonObject(with:remoteData, options: .allowFragments)
                    let resultArray = newData as! Array<Any>
                    let keliArray = resultArray[0] as! Array<Any>
                    if(keliArray.count == 0){
                        return
                    }
                    if(keliArray[0] is NSNull){
                        return
                    }
                    let commentArray = resultArray[1] as! Array<Any>
                    
                    for i in 0..<keliArray.count {
                        
                        let thisKeli = Keli()
                        let newDict:[String:Any] = keliArray[i] as! [String: Any]
                        
                        if let id_keli = newDict["id_keli"] {
                            thisKeli.id_keli = Int(id_keli as! String)!
                        }
                        
                        if let id_job = newDict["id_job"] {
                            thisKeli.id_job = Int(id_job as! String)!
                        }
                        
                        if let keli_from_userid = newDict["keli_from_userid"] {
                            
                            thisKeli.keli_from_userid = keli_from_userid as! String
                        }
                        
                        if let keli_to_userid = newDict["keli_to_userid"] {
                            thisKeli.keli_to_userid = keli_to_userid as! String
                        }
                        
                        if let keli_to_groupid = newDict["keli_to_groupid"] {
                            thisKeli.keli_to_groupid = Int(keli_to_groupid as! String)!
                        }
                        
                        if let created = newDict["created"] {
                            
                            if let date = ConstValue.convertDateFromString(created as? String) {
                                
                                thisKeli.created = date
                            }
                            
                        }
                        if let accepted = newDict["accepted"] {
                            let bool = Int(accepted as! String)!
                            if(bool == 1){
                                thisKeli.accepted = true
                            } else {
                                thisKeli.accepted = false
                            }
                        }
                        if let id_keli_before = newDict["id_keli_before"] {
                            thisKeli.id_keli_before = Int(id_keli_before as! String)!
                        }
                        
                        KeliManager.addNewKeli(keli:thisKeli)
                    }
                    
                    for i in 0..<commentArray.count {
                        let thisComment = Comment()
                        let newDict:[String:Any] = commentArray[i] as! [String:Any]
                        
                        if let id_comment = newDict["id_comment"] {
                            thisComment.id_comment = Int(id_comment as! String)!
                        }
                        
                        if let id_user = newDict["id_user"] {
                            thisComment.id_user = id_user as! String
                        }
                        
                        if let id_keli = newDict["id_keli"] {
                            thisComment.id_keli = Int(id_keli as! String)!
                        }
                        
                        if let  comment = newDict["comment"] as! String? {
                            thisComment.comment = comment
                        }
                        
                        if let created = newDict["created"] as! String? {
                            if let date = ConstValue.convertDateFromString(created) {
                                thisComment.created = date
                            }
                        }
                        
                        if let modified = newDict["modified"] as! String? {
                            if let date = ConstValue.convertDateFromString(modified) {
                                thisComment.modified = date
                            }
                        }
                        CommentManager.addNewComment(comment: thisComment)
                    }
                    
                } catch {
                    
                    print("JSON error occured in downloadNewestKelis()(or there is no data)")
                    
                }
            
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        }catch {
            print("json error in downloadNewestKelis")
        }
    }
    
    static func getNewestDataForPush() {
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        guard let newestModified = KeliManager.getNewestModifiedDate() else {
            return
        }

        let postDict = ["uid":uid,"modified":newestModified]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestKelis
            let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
            let manager = KeliManager()
            manager.postMethodWithDelegateMethod(urlString: url, data: jsonData)
            
        } catch {
            
        }
    }
    
    func postMethodWithDelegateMethod(urlString:String, data:Data){
        
        let url = URL(string: urlString)
        
        //デバッグ用
        let str: String! = String(data: data, encoding: .utf8)
        print("data in postMethod / url",str, urlString)
        
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.httpBody = data
        //let config = URLSessionConfiguration.default
        //↓ここが違う
        let config = URLSessionConfiguration.background(withIdentifier: "background")
        //↑ここが違う
        let urlSession = URLSession(configuration: config, delegate:self, delegateQueue: nil)
        let sessionTask = urlSession.dataTask(with: request)
        sessionTask.resume()
        urlSession.finishTasksAndInvalidate()
        
    }
    
    public func urlSession(_ session: URLSession,
                    dataTask: URLSessionDataTask,
                    didReceive data: Data){
        
        do {
            
            let remoteData = data
            let newData: Any = try JSONSerialization.jsonObject(with:remoteData, options: .allowFragments)
            let resultArray = newData as! Array<Any>
            let keliArray = resultArray[0] as! Array<Any>
            let commentArray = resultArray[1] as! Array<Any>
            var globalCount = Int()
            
            for i in 0..<keliArray.count {
                
                let thisKeli = Keli()
                let newDict:[String:Any] = keliArray[i] as! [String: Any]
                
                if let id_keli = newDict["id_keli"] {
                    thisKeli.id_keli = Int(id_keli as! String)!
                }
                
                if let id_job = newDict["id_job"] {
                    thisKeli.id_job = Int(id_job as! String)!
                }
                
                if let keli_from_userid = newDict["keli_from_userid"] {
                    
                    thisKeli.keli_from_userid = keli_from_userid as! String
                }
                
                if let keli_to_userid = newDict["keli_to_userid"] {
                    thisKeli.keli_to_userid = keli_to_userid as! String
                }
                
                if let keli_to_groupid = newDict["keli_to_groupid"] {
                    thisKeli.keli_to_groupid = Int(keli_to_groupid as! String)!
                }
                
                if let created = newDict["created"] {
                    
                    if let date = ConstValue.convertDateFromString(created as! String) {
                        
                        thisKeli.created = date
                    }
                    
                }
                if let accepted = newDict["accepted"] {
                    let bool = Int(accepted as! String)!
                    if(bool == 1){
                        thisKeli.accepted = true
                    } else {
                        thisKeli.accepted = false
                    }
                }
                if let id_keli_before = newDict["id_keli_before"] {
                    thisKeli.id_keli_before = Int(id_keli_before as! String)!
                }
                //userDefaultでカウントをincrementして反映する
                //現在の数をバッジに反映する
                KeliManager.addNewKeli(keli:thisKeli)
                globalCount += 1
            }
            
            //上記ループを抜けた時点でいくつ増えたかをUserDefaultに記録
            ManipulateUserDefaults.setKeliCountForBadge(num: globalCount)
            registerForBadge()
            
            
            for i in 0..<commentArray.count {
                let thisComment = Comment()
                let newDict:[String:Any] = commentArray[i] as! [String:Any]
                
                if let id_comment = newDict["id_comment"] {
                    thisComment.id_comment = Int(id_comment as! String)!
                }
                
                if let id_user = newDict["id_user"] {
                    thisComment.id_user = id_user as! String
                }
                
                if let id_keli = newDict["id_keli"] {
                    thisComment.id_keli = Int(id_keli as! String)!
                }
                
                if let  comment = newDict["comment"] as! String? {
                    thisComment.comment = comment
                }
                
                if let created = newDict["created"] as! String? {
                    if let date = ConstValue.convertDateFromString(created) {
                        thisComment.created = date
                    }
                }
                
                if let modified = newDict["modified"] as! String? {
                    if let date = ConstValue.convertDateFromString(modified) {
                        thisComment.modified = date
                    }
                }
                CommentManager.addNewComment(comment: thisComment)
            }
            
        } catch {
            
            print("JSON error occured in downloadNewestKelis()(or there is no data)")
            
        }
        
        
    }
    
    func registerForBadge() {
        
        let num = ManipulateUserDefaults.getKeliCountForBadge()
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = num!
        
    }

    
    /**
     リモートと比較するため最新のmodifiedを検索する
     */
    static func getNewestModifiedDate() -> String? {
        
        let allKelis = KeliManager.getAllObjects()
        let newestModifiedJob = allKelis.sorted(byProperty:"modified", ascending: false)
        
        if(newestModifiedJob.count == 0){
            return "2000-01-01 00:00:00"
        }
        
        if let newestDate:Date = newestModifiedJob[0].modified as Date? {
            return ConstValue.stringFromDate(date: newestDate)
        } else {
            return "2000-01-01 00:00:00"
        }
        
    }
    
    static func getActors(keli:Keli) -> [User]{
        
        let senderUser = UserManager.queryUserById(id_user: keli.keli_from_userid)
        let senderUserName: String? = senderUser?.name
        
        var actorsArray = [User]()
        if(senderUserName != nil){
            actorsArray.append(senderUser!)
        } else {
            //リモートに問い合わせてRealmへ
            actorsArray.append(User())
            let resultHandler = {(user:User)->Void
                in
                //結果は一応取得するが、セルの表示を優先させるため, 空のUserを返す
                //セルにはいずれremoteから得たデータが表示される
                
            }
            KeliManager.getUserForKeli(uid:keli.keli_from_userid, resultHandler)
        }
      
        
        
        let destinationUser = UserManager.queryUserById(id_user: keli.keli_to_userid)
        let destinationUserName: String? = destinationUser?.name

        if(destinationUserName != nil){
            actorsArray.append(destinationUser!)
        } else {
            //リモートに問い合わせてRealmへ
            actorsArray.append(User())
            let resultHandler = {(user:User)->Void
                in
                //結果は一応取得するが、セルの表示を優先させるため, 空のUserを返す
                //セルにはいずれremoteから得たデータが表示される
            }
            KeliManager.getUserForKeli(uid:keli.keli_to_userid, resultHandler)
        }
        
        
        return actorsArray
    }
    
    static func getUserForKeli(uid:String, _ resultHandler:@escaping (_ user:User)->Void){
        
        let postDict = ["uid":uid]
        do {
            if(uid.characters.count == 0){
                return
            }
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getUser.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, err:Error?) -> Void
                in
                do {
                    
                    if(data == nil){
                        return
                    }
                    
                    let decodedDeta = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    guard let resultArray = decodedDeta as? Array<Any> else {
                        return
                    }
                    if(resultArray.count == 0){
                        return
                    }
                    let friend:Any? = resultArray[0] as Any?
                    
                    // for i in 0..<friendArray.count {
                    let thisUser = User()
                    let newDict:[String:Any] = friend as! [String:Any]
                    
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
                        print("photoURL",photoURL)
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
                
                    //得られたデータのユーザーは友達ではないのでFriendsテーブルにはデータを入れない
                    print("thisUser", thisUser)
                    UserManager.addNewFriends(friend: thisUser)
                    resultHandler(thisUser)

                } catch {
                    
                }
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            
        }
    }
    
    
    static func getAllObjects() -> Results<Keli>{
        let realm = try! Realm()
        let kelis = realm.objects(Keli.self).sorted(byProperty: "id_keli", ascending: false)
        return kelis
    }
    
    /**
     いまRealm内にあるKeliからidの配列のみを返す
 　　*/
    static func getAllIdKelis() -> [Int] {
    
        let allKelis = KeliManager.getAllObjects()
        var ids_keli = [Int]()
        
        for keli in allKelis {
            ids_keli.append(keli.id_keli)
        }
        
        return ids_keli
        
    }
    
    static func getObjectsByKeliId(id_keli:Int) -> Results<Keli> {
        let realm = try! Realm()
        let kelis = realm.objects(Keli.self).filter("id_keli = %@", id_keli).sorted(byProperty: "modified", ascending: false)
        return kelis
    }
    
    static func returnJobIdByIdKeli(id_keli:Int) -> Int {
        let realm = try! Realm()
        let kelis = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
        return kelis[0].id_job
    }
    
    static func queryUke_KelisByIdUser(id_user:Int) -> Results<Keli>? {
        let realm = try! Realm()
        //自分宛でありacceptedのの場合は自分が受けたケリとなる
        let kelis = realm.objects(Keli.self).filter("keli_to_userid = %@ AND accepted = true",id_user)
        print("kelis in queyrUke_Kelis %@", kelis)
        return kelis
    }
    
    static func queryKeliByIdJob(id_job:Int) -> Results<Keli>? {
        let realm = try! Realm()
        //最新のKeliを最上位にして値を返す
        let kelis = realm.objects(Keli.self).filter("id_job = %@", id_job).sorted(byProperty: "modified", ascending:false)
        return kelis
    }
    
    static func queryKeliByIdKelibefore(id_keli: Int) -> Results<Keli>? {
        let realm = try! Realm()
        let kelis = realm.objects(Keli.self).filter("id_keli_before = %@", id_keli)
        return kelis
    }
    
    static func queryJobByIdKeli(id_keli: Int) -> Results<Job>? {
        let realm = try! Realm()
        let kelis = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
        let id_job = kelis[0].id_job
        let jobs = realm.objects(Job.self).filter("id_job = %@", id_job)
        return jobs
    }
    
    static func addNewKeli(keli:Keli){
        let realm = try! Realm()
        try! realm.write {
            realm.add(keli, update:true)
        }
    }
    
    static func deleteAllObjects() {
        let realm = try! Realm()
        try! realm.write {
            
            let kelis = realm.objects(Keli.self)
            realm.delete(kelis)
        }
    }
    
    static func getGroupNameByIdKeli(id_keli: Int) -> String? {
        let realm = try! Realm()
        let thisKeli = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
        let id_group = thisKeli[0].keli_to_groupid
        let thisGroup = GroupManager.queryGroupByGroupid(id_group: id_group)
        if(thisGroup.count == 0){
            return ""
        }
        let groupName = thisGroup[0].name
        return groupName
    }
    
    static func getAKeliDictByIdKeli(id_keli: Int) -> [String:Any] {
        let realm = try! Realm()
        let thisKeli = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
        let id_keli = thisKeli[0].id_keli
        let id_job = thisKeli[0].id_job
        let keli_from_userid = thisKeli[0].keli_from_userid
        let keli_to_userid = thisKeli[0].keli_to_userid
        let keli_to_groupid = thisKeli[0].keli_to_groupid
        let id_keli_before = thisKeli[0].id_keli_before
        let created = thisKeli[0].created
        let modified = thisKeli[0].modified
        let accepted = thisKeli[0].accepted
        let dict = ["id_keli":id_keli, "id_job":id_job, "keli_from_userid":keli_from_userid, "keli_to_userid": keli_to_userid, "keli_to_groupid":keli_to_groupid, "id_keli_before":id_keli_before, "created":created, "modified":modified, "accepted":accepted] as [String : Any]
        return dict
        
    }

/*deprecated
     サーバー側でinsertする
 */
//    static func setAcceptedByIdjob(id_job:Int, keli_to_userid:String){
//        let realm = try! Realm()
//        let queriedKeli : Results<Keli> = realm.objects(Keli.self).filter("id_job = %@ And keli_to_userid = %@", id_job, keli_to_userid)
//        //Realmの結果の有無を調べるにはこの方法がよいみたい
//        if(queriedKeli.count == 0){
//            return
//        }
//        try! realm.write {
//            queriedKeli[0].accepted = true
//        }
//        print("queriedKeli = %@", queriedKeli)
//    }
//    
//    static func setAcceptedByIdkeli(id_keli:Int){
//        let realm = try! Realm()
//        let queriedKeli : Results<Keli> = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
//        //Realmの結果の有無を調べるにはこの方法がよいみたい
//        if(queriedKeli.count == 0){
//            return
//        }
//        try! realm.write {
//            queriedKeli[0].accepted = true
//        }
//        print("queriedKeli = %@", queriedKeli)
//    }
//    
    
    static func changeKeliToUserIdForTest(id_keli:Int, keli_to_userid:String) {
        let realm = try! Realm()
        try! realm.write {
            let thisJob = realm.objects(Keli.self).filter("id_keli = %@", id_keli)
            thisJob[0].keli_to_userid = keli_to_userid
        }
    }
}

/**
 Keliに完全従属するため、getNewest時はget_newest_keli内で取得される
 */
public class Comment : Object {
    
    dynamic var id_comment: Int = 0
    dynamic var id_keli : Int = 0
    dynamic var id_job : Int = 0
    dynamic var comment : String? = nil
    dynamic var id_user : String = ""
    dynamic var created = Date()
    dynamic var modified = Date()
    
    override public static func primaryKey() -> String? {
        return "id_comment"
    }
    
}

public class CommentManager {

    static func getAllObjects() -> Results<Comment> {
        let realm = try! Realm()
        let objects = realm.objects(Comment.self)
        return objects
    }
    
    static func deleteAllObjects() {
        let realm = try! Realm()
        try! realm.write {
            
            let objects = realm.objects(Comment.self)
            realm.delete(objects)
        }
        
    }
    
    static func addNewComment(comment:Comment) {
        let realm = try! Realm()
        try! realm.write {
            realm.add(comment, update:true)
        }
    }
    
    //最新のコメントを取得する
    static func queryCommentByIdKeli(id_keli:Int) -> Results<Comment> {
        let realm = try! Realm()
        let queriedObjects = realm.objects(Comment.self).filter("id_keli = %@", id_keli).sorted(byProperty: "modified", ascending: false)
        return queriedObjects
        
    }
    
    static func queryCommentByIdUser(id_user:Int) -> Results<Comment> {
        let realm = try! Realm()
        let queriedObjects = realm.objects(Comment.self).filter("id_user = %@", id_user)
        return queriedObjects
    }
    
    static func queryCommentByIdJob(id_job:Int) -> Results<Comment> {
        let realm = try! Realm()
        let queriedObjects = realm.objects(Comment.self).filter("id_job = %@", id_job)
        return queriedObjects
    }
    
}

