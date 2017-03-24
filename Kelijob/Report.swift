//
//  Report.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/20.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class Report : Object {
    
    dynamic var id_report : Int = 0
    dynamic var id_job : Int = 0
    dynamic var id_keli : Int = 0
    dynamic var id_user : String = ""
    dynamic var comment : String? = nil
    dynamic var done : Bool = false
    dynamic var created = Date()
    dynamic var modified = Date()
    dynamic var image : String? = nil
    
    override public static func primaryKey() -> String? {
        return "id_report"
    }

}

class ReportManager {
    
    /**
     ## リモートDBからデータを取得してRealmに挿入する
     - RealmにあるJobのidを利用してデータを取得する
     - Jobが最新の状態にあることを確認してから実行すること
     */
    static func downloadDataFromRemote() {
        //id_userとie_jobのリストをPOSTする
        guard let id_user = ManipulateUserDefaults.getUserid() else {
            return
        }
        let ids_job = JobManager.getAllIdJobs()
        print(ids_job.description)
        let dataDict:[String:Any] = ["id_user":id_user, "ids_job":ids_job]
        do {
            let jsonObject = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getAllReports
            let url = DomainManager.readDomainPlist(key: urlKey.rawValue)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void in
            
                do {
                    if(data == nil){
                        return
                    }
                    let reportData:Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let newData = reportData as! Array<Any>
                    
                    for i in 0..<newData.count {
                        let thisReport = Report();
                        let newDict:[String:Any?] = newData[i] as! [String:Any]
                        if let id_report = newDict["id_report"] {
                            thisReport.id_report = id_report as! Int
                        }
                        
                        if let id_job = newDict["id_job"]{
                            thisReport.id_job = id_job as! Int
                        }
                        
                        if let id_keli = newDict["id_keli"] {
                            thisReport.id_keli = id_keli as! Int
                        }
                        
                        if let id_user = newDict["id_user"] {
                            thisReport.id_user = id_user as! String
                        }
                        
                        if let comment = newDict["comment"] {
                            thisReport.comment = comment as? String
                        }
                        
                        if let done = newDict["done"] {
                            let bool = Int(done as! String)!
                            if(bool == 1){
                                thisReport.done = true
                            } else {
                                thisReport.done = false
                            }
                        }
                        
                        if let created = newDict["created"] {
                            if let thisDate = ConstValue.convertDateFromString(created as! String) {
                                thisReport.created = thisDate
                            }
                        }
                        
                        if let modified = newDict["modified"] {
                            if let thisDate = ConstValue.convertDateFromString(modified as! String){
                                thisReport.modified = thisDate
                            }
                        }
                        
                        if let image = newDict["image"] {
                            thisReport.image = image as? String
                        }
                        
                        ReportManager.addNewObject(object: thisReport)
                    }
                    
                } catch {
                    
                }
                
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonObject, completionHandler: completionHandler)
            
        } catch {
            
        }
        
    }
    
    static func downloadNewestReports() {
        
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        guard let newestModified = ReportManager.getNewestModifiedDate() else {
            return
        }
        let ids_job = JobManager.getAllIdJobs()
        let postDict = ["id_user":uid, "ids_job":ids_job, "modified":newestModified] as [String : Any]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestReports
            let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
            let completionHandler = {(_ data: Data?, _resp: URLResponse?, _error: Error?) -> Void in
                
                do {
                    
                    guard let remoteData = data else{
                        return
                    }
                    
                    let newData: Any = try JSONSerialization.jsonObject(with:remoteData, options: .allowFragments)
                    let reportArray = newData as! Array<Any>
                    
                    for i in 0..<reportArray.count {
                        let thisReport = Report();
                        let newDict:[String:Any?] = reportArray[i] as! [String:Any]
                        if let id_report = newDict["id_report"] {
                            thisReport.id_report = Int(id_report as! String)!
                        }
                        
                        if let id_job = newDict["id_job"]{
                            thisReport.id_job = Int(id_job as! String)!
                        }
                        
                        if let id_keli = newDict["id_keli"] {
                            thisReport.id_keli = Int(id_keli as! String)!
                        }
                        
                        if let id_user = newDict["id_user"] {
                            thisReport.id_user = id_user as! String
                        }
                        
                        if let comment = newDict["comment"] {
                            thisReport.comment = comment as? String
                        }
                        
                        if let done = newDict["done"] {
                            if(done as! String == "0"){
                                thisReport.done = false
                            } else {
                                thisReport.done = true
                            }
                        }
                        
                        if let created = newDict["created"] {
                            if let thisDate = ConstValue.convertDateFromString(created as! String) {
                                thisReport.created = thisDate
                            }
                        }
                        
                        if let modified = newDict["modified"] {
                            if let thisDate = ConstValue.convertDateFromString(modified as! String){
                                thisReport.modified = thisDate
                            }
                        }
                        
                        if let image = newDict["image"] {
                            thisReport.image = image as? String
                        }
                        
                        ReportManager.addNewObject(object: thisReport)
                    }
                    
                } catch {
                    
                    print("JSON error occured in downloadNewestReports()(or there is no data)")
                    
                }
                
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)

            
        } catch {
            
        }
        
        
    }
    
    static func getNewestModifiedDate() -> String? {
       
        let allReports = ReportManager.getAllObjects()
        let newestModifiedReport = allReports.sorted(byProperty:"modified", ascending: false)
        
        if(newestModifiedReport.count == 0){
            return "2000-01-01 00:00:00"
        }
        
        if let newestDate:Date = newestModifiedReport[0].modified as Date? {
            return ConstValue.stringFromDate(date: newestDate)
        } else {
            return "2000-01-01 00:00:00"
        }
        
    }
    
    static func getAllObjects() -> Results<Report> {
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self)
        return objects
    }
    
    static func deleteAllObjects(){
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self)
        
        try! realm.write {
            realm.delete(objects)
        }
    }
    
    static func addNewObject(object:Report) {
        let realm : Realm
        realm = try! Realm()
        try! realm.write {
            realm.add(object, update:true)
        }
    }
    
    static func queryReportByIdJob(id_job:Int?) -> Results<Report> {
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self).filter("id_job = %@",id_job!).sorted(byProperty: "modified", ascending: true)
        return objects
    }
    
    static func queryReportByIdKeli(id_keli:Int?) -> Results<Report> {
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self).filter("id_keli = %@",id_keli!).sorted(byProperty: "modified", ascending: false)
        return objects
    }
    
    static func queryReportByIdUser(id_user:String?) -> Results<Report> {
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self).filter("id_user = %@ AND done = false", id_user)
        return objects
    }
    
    //doneしていないreportのみを検出する
    static func queryInProgressReportByIdUser(id_user:Int) -> Results<Report> {
        let realm : Realm
        realm = try! Realm()
        let objects = realm.objects(Report.self).filter("id_user = %@ AND done = false", id_user)
        return objects
    }
    
    static func getLatestComment(id_user:Int, reportArray:Results<Report>) -> String {
        
        if(reportArray.count == 0){
            return ""
        }
        let thisResult = reportArray[0]
        let thisComment = thisResult.comment
        return thisComment!
    }
    
}
