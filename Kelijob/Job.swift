//
//  Job.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

public class Job : Object {
    
    dynamic var id_job : Int = 0
    dynamic var id_user : String = ""
    //TODO:optional0で良いか
    dynamic var id_group : Int = 0
    dynamic var title : String? = nil
    dynamic var job_description : String? = nil
    dynamic var modified : Date? = nil
    dynamic var created = Date()
    dynamic var done : Bool = false
    //dynamic var in_progress : Bool = false
    dynamic var receiver_id_user : String = ""
    
    override public static func primaryKey() -> String? {
        return "id_job"
    }
}

class JobManager {
    
    /**
     ##リモートからデータをロードしてRealmに入れる
     - Remote:所属するグループに紐づくJob
     - Remote:いちどでも蹴ったことのあるJob(Keliからid_jobを抽出)
     - Remote:receiver_id_userが自分のJob
     */
    static func downloadJobDataFromRemote(){
    
        let urlKey = DomainManager.DomainKeys.getAllJobs
        let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
        let uid = ManipulateUserDefaults.getUseridOfJSON()
        let completionHandler = {(_ data:Data?,_ resp:URLResponse?, _ err:Error?) -> Void in
            
            do {
                
                if(data == nil){
                    return
                }
                let jobData: Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                let newData = jobData as! Array<Any>
                
                for i in 0..<newData.count {
                    
                    let thisJob = Job()
                    let newDict:[String:Any] = newData[i] as! [String: Any]
                    
                    if let id_job = newDict["id_job"] {
                        thisJob.id_job = id_job as! Int
                    }
                    
                    if let id_group = newDict["id_group"]{
                        thisJob.id_group = id_group as! Int
                    }
                    
                    if let title = newDict["title"] {
                        thisJob.title = title as? String
                    }
                    
                    if let job_description = newDict["job_description"] {
                        //TODO:nilチェックエラーテスト
                        thisJob.job_description = job_description as? String
                    }
                    
                    if let modified = newDict["modified"] as? String? {
                        if let date = ConstValue.convertDateFromString(modified!) {
                            thisJob.modified = date
                        }
                    }
                    
                    if let created = newDict["created"] as? String? {
                        if let date = ConstValue.convertDateFromString(created!) {
                            thisJob.created = date
                        }
                        
                    }
                    
                    if let done = newDict["done"] {
                        let bool = Int(done as! String)!
                        if(bool == 1){
                            thisJob.done = true
                        } else {
                            thisJob.done = false
                        }
                    }
                    
                    if let receiver_id_user = newDict["receiver_id_user"] {
                        thisJob.receiver_id_user = receiver_id_user as! String
                    }
                
                    JobManager.addNewJob(job: thisJob);
                }
                
            } catch {
                
            }
            
        }
        KeliConnection.postMethodWithCompletionHandler(urlString: url, data: uid!, completionHandler: completionHandler)
    
    }
    
    static func downloadNewestJobs() {
        
        guard let newestModifiedDate:String = JobManager.getNewestModifiedDate() else {
            return
        }
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        let postData = ["uid":uid, "modified":newestModifiedDate]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestJobs.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?,_ resp:URLResponse?, _ err:Error?) -> Void in
                
                do {
                    
                    if(data == nil){
                        return
                    }
                    let jobData: Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let newData = jobData as! Array<Any>
                    
                    for i in 0..<newData.count {
                        
                        let thisJob = Job()
                        let newDict:[String:Any] = newData[i] as! [String: Any]
                        
                        if let id_job = newDict["id_job"] {
                            thisJob.id_job = Int(id_job as! String)!
                        }
                        
                        if let id_user = newDict["id_user"] {
                            thisJob.id_user = id_user as! String
                        }
                        
                        if let id_group = newDict["id_group"]{
                            thisJob.id_group = Int(id_group as! String)!
                        }
                        
                        if let title = newDict["title"] {
                            thisJob.title = title as? String

                        }
                        
                        if let job_description = newDict["job_description"] {
                            //TODO:nilチェックエラーテスト
                            thisJob.job_description = job_description as? String
                        }
                        
                        if let modified = newDict["modified"] as? String? {
                            if let date = ConstValue.convertDateFromString(modified!) {
                                thisJob.modified = date
                            }
                        }
                        
                        if let created = newDict["created"] as? String? {
                            if let date = ConstValue.convertDateFromString(created!) {
                                thisJob.created = date
                            }
                            
                        }
                        
                        if let done = newDict["done"] as! String? {
                            if(done == "0"){
                                thisJob.done = false
                            } else {
                                thisJob.done = true
                            }
                           
                        }
                        
                        if let receiver_id_user = newDict["receiver_id_user"] {
                            thisJob.receiver_id_user = receiver_id_user as! String
                        }
                        print("thisJob in dl newest jobs", thisJob)
                        JobManager.addNewJob(job: thisJob);
                    }
                    
                } catch {
                    
                }
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            
        }
    }
    
    static func getJobsByReceiverId(id_receiver:String, resultHandler:@escaping ([[[String:Any]]])->Void) {
        
        let postData = ["id_receiver":id_receiver]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postData, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getJobsByReceiver.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
            in
                //エラーアラートを表示
                if let response = resp as! HTTPURLResponse? {
                    let statusCode = response.statusCode
                    if(statusCode != 200){
                        AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                        return
                    }
                }
                
                if(err != nil){
                    
                    AlertControllerManager.showAlertController("エラーです", "しばらくしてから\nもういちどお試しください", nil)
                    return
                }
               
                
                if(data == nil){
                    return
                }
                do {
                    let userData: Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let newData: Array<Any> = userData as! Array<Any>
                    let doingJobData:[[String:Any]] = newData[0] as! [[String : Any]]
                    let doneJobData:[[String:Any]] = newData[1] as! [[String:Any]]
                    
                    var resultDoingJobArray = [[String:Any]]()
                    for i in 0..<doingJobData.count {
                        var thisJob = [String:Any]()
                        let newDict:[String:Any] = doingJobData[i]
                        
                        if let id_job = newDict["id_job"] {
                            thisJob["id_job"] = id_job
                        }
                        if let id_group = newDict["id_group"] {
                            thisJob["id_group"] = id_group
                        }
                        if let title = newDict["title"] {
                            thisJob["title"] = title
                        }
                        if let job_description = newDict["job_description"] {
                            thisJob["job_description"] = job_description
                        }
                        
                        if let modified = newDict["modified"] {
                            thisJob["modified"] = modified
                        }
                        if let created = newDict["created"] {
                            thisJob["created"] = created
                        }
                        if let done = newDict["done"] {
                            thisJob["done"] = done
                        }
                        if let receiver_id_user = newDict["receiver_id_user"] {
                            thisJob["receiver_id_user"] = receiver_id_user
                        }
                        resultDoingJobArray.append(thisJob)
                        
                    }
                    
                    var resultDoneJobArray = [[String:Any]]()
                    for i in 0..<doneJobData.count {
                        var thisJob = [String:Any]()
                        let newDict:[String:Any] = doneJobData[i]
                        
                        if let id_job = newDict["id_job"] {
                            thisJob["id_job"] = id_job
                        }
                        if let id_group = newDict["id_group"] {
                            thisJob["id_group"] = id_group
                        }
                        if let title = newDict["title"] {
                            thisJob["title"] = title
                        }
                        if let job_description = newDict["job_description"] {
                            thisJob["job_description"] = job_description
                        }
                        
                        if let modified = newDict["modified"] {
                            thisJob["modified"] = modified
                        }
                        if let created = newDict["created"] {
                            thisJob["created"] = created
                        }
                        if let done = newDict["done"] {
                            thisJob["done"] = done
                        }
                        if let receiver_id_user = newDict["receiver_id_user"] {
                            thisJob["receiver_id_user"] = receiver_id_user
                        }
                        resultDoneJobArray.append(thisJob)
                        
                    }
                    
                    let newArray = [resultDoingJobArray, resultDoneJobArray]
                    //resultHandlerで結果を渡す
                    resultHandler(newArray as! [[[String:Any]]])
                
                    
                } catch {
                    
                }
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            
        }
    }
    
    /**
     リモートと比較するため最新のmodifiedを検索する
     -　データがない時、デフォルト値を返す
    */
    static func getNewestModifiedDate() -> String? {
        
        let allJobs = JobManager.getAllObjects()
        let newestModifiedJob = allJobs.sorted(byProperty:"modified", ascending: false)
        if(newestModifiedJob.count == 0){
            return "2000-01-01 00:00:00"
        }
        if let newestDate:Date = newestModifiedJob[0].modified as Date? {
            return ConstValue.stringFromDate(date: newestDate)
        } else {
            return "2000-01-01 00:00:00"
        }
        
    }
    
    /**
     いまRealm内にあるJobからidの配列のみを返す
     　　*/
    static func getAllIdJobs() -> [Int] {
        
        let allJobs = JobManager.getAllObjects()
        var ids_job = [Int]()
        
        for job in allJobs {
            ids_job.append(job.id_job)
        }
        
        return ids_job
        
    }

    
    static func queryRemoteMissingJob(){
        
    }

    /**
     modified降順に結果を返す
 　　*/
    static func getAllObjects() -> Results<Job>{
        let realm : Realm
        do {
            realm = try Realm()
            let objects = realm.objects(Job.self).sorted(byProperty: "modified", ascending:false)
            return objects
        } catch {
            fatalError("Resultsオブジェクトでかえす限り、Realmエラーでは落とすしかない。リファクタするなら配列を返すようにする")
        }
    }
 
    static func addNewJob(job:Job) {
        let realm : Realm
        do{
            realm = try Realm()
            try! realm.write {
                realm.add(job, update:true)
            }
        }catch{
            print("error in addnewjob")
        }
    }
    
    //realmからmodified順にソートしてオブジェクトを返す
    static func sortedJobs() -> Results<Job> {
        let realm = try! Realm()
        let sortedJobs = realm.objects(Job.self).sorted(byProperty:"modified")
        return sortedJobs
    }
    
    //id_jobを受け取り検索して返す
    static func queryJobById(id_job:Int) -> Results<Job> {
        let realm = try! Realm()
        let queriedJob = realm.objects(Job.self).filter("id_job = %@", id_job)
        return queriedJob
    }
    
    //自分の発行したjobだけを返す
    static func myCreatedJobs() -> Results<Job> {
        let realm = try! Realm()
        let myid = ManipulateUserDefaults.getUserid()
        let queriedJob = realm.objects(Job.self).filter("user_id = %@", myid ?? "")
        return queriedJob
    }
    
    //指定したid_userのjobを返す
    static func userJobs(id_user:Int) -> Results<Job> {
        let realm = try! Realm()
        let queriedJob = realm.objects(Job.self).filter("user_id = %@", id_user)
        return queriedJob
    }
    
    //すべてのobjectを消去する
    //新しく取得する前に実行すること
    static func deleteAllObject(){
        let realm = try! Realm()
        try! realm.write {
            let allItems = realm.objects(Job.self)
            realm.delete(allItems)
        }
    }
    
    //通常の削除であれば、サーバーに投げて結果を反映する
    //初回のデータベース構築時のメソッドについては、通信実装しながら行う
    

    //jobを再生成して返却する
    //呼び出しもとでもとのインスタンスは破棄すること
    static func editTitle(job:Job, newTitle:String) -> Job? {
        let tmpJob = job
        if(ManipulateUserDefaults.equalToUserid(userid: job.id_user)){
            tmpJob.title = newTitle
           return tmpJob
        }else{
            return nil
       }
    }
    
    static func editDescription(job:Job, newDesc:String) -> Job? {
        if(ManipulateUserDefaults.equalToUserid(userid: job.id_user)){
            let tmpJob = job
            tmpJob.job_description = newDesc
            return tmpJob
        }else{
            return nil
        }
    }
    
    static func insertModifiedDate(job:Job) -> Job {
        let tmpJob = job
        tmpJob.modified = Date()
        return tmpJob
    }
    

    
    static func updateReceiveridForTest(receiver_id_user:String, id_job:Int){
        let realm = try! Realm()
        try! realm.write {
            let objects = realm.objects(Job.self).filter("id_job = %@", id_job)
            objects[0].receiver_id_user = receiver_id_user
        }
    }
    
    //Jobを受けた人でソートし、modified順に降順に並べて返す
    static func queryJobByReceiver(receiver_id_user:String) -> Results<Job> {
        let realm = try! Realm()
        let objects = realm.objects(Job.self).filter("receiver_id_user = %@",receiver_id_user).sorted(byProperty: "modified", ascending: false)
        return objects
    }
    
    static func queryDoneJobByReceiver(receiver_id_user:String) -> Results<Job> {
        let realm = try! Realm()
        let objects = realm.objects(Job.self).filter("receiver_id_user = %@", receiver_id_user).filter("done = %@", true).sorted(byProperty: "modified", ascending:false)
        return objects
    }
    
    static func queryDoingJobByReceiver(receiver_id_user:String) -> Results<Job> {
        let realm = try! Realm()
        let objects = realm.objects(Job.self).filter("receiver_id_user = %@", receiver_id_user).filter("done = %@", false).sorted(byProperty: "modified", ascending:false)
        return objects
    }
    
    //結果がないとき空の辞書がかえる
    static func getAJobDictByIdJob(id_job:Int) -> [String:Any] {
        
        let realm = try! Realm()
        let objects = realm.objects(Job.self).filter("id_job = %@", id_job)
        var dict = [String:Any]()
        if(objects.count > 0) {
            let resultJob = objects[0]
            let id_job = resultJob.id_job
            let id_user = resultJob.id_user
            let title = resultJob.title
            let job_description = resultJob.job_description
            let created = resultJob.created
            let modified = resultJob.modified
            let defaultDate: Date = ConstValue.convertDateFromString(nil)!
            let done = resultJob.done
            let receiver_id_user = resultJob.receiver_id_user
            dict = ["id_job":id_job,"id_user":id_user, "title":title ?? "", "job_description":job_description ?? "", "created":created, "modified":modified ?? defaultDate, "done":done, "receiver_id_user":receiver_id_user]
            
        }
       
        return dict
    }
}
