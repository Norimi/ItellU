//
//  Group.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/20.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

public class Group : Object {
    
    dynamic var name : String = ""
    dynamic var id_group : Int = 0
    dynamic var group_description : String? = nil
    dynamic var created = Date()
    dynamic var modified = Date()
    override public static func primaryKey() -> String? {
        return "id_group"
    }
    //リモートにはない定義
    let friends = List<User>()
}

class GroupManager {
    
    static func downloadNewestGroups() {
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        let thisDate = ManipulateUserDefaults.getNewestGroupRelationModifiedDate()
        let dateString = ConstValue.stringFromDate(date: thisDate!)
        let postDict = ["uid":uid, "modified":dateString]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.getNewestGroup.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
            
                in
                do {
                    if(data == nil){
                        return
                    }
                    let decodedData:Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                    let resultArray = decodedData as! Array<Any>
                    if(resultArray[0] is NSNull){
                        return
                    }
                    let modifiedDate = resultArray[0] as! String
                    let groupArray:Array<Any> = resultArray[1] as! Array<Any>
                    
                    for i in 0..<groupArray.count {
                        
                        let thisGroup = Group()
                        let newDict:[String:Any] = groupArray[i] as! [String:Any]
                        
                        if let id_group = newDict["id_group"] {
                            thisGroup.id_group = Int(id_group as! String)!
                        }
                        if let name = newDict["name"] {
                            thisGroup.name = name as! String
                        }
                        if let description = newDict["group_description"] {
                            thisGroup.group_description = description as! String
                        }
                        if let created: String = newDict["created"] as! String? {
                            if let newDate = ConstValue.convertDateFromString(created){
                                thisGroup.created = newDate
                                
                            }
                        }
                        if let modified: String = newDict["modified"] as! String? {
                            if let newDate = ConstValue.convertDateFromString(modified){
                                thisGroup.modified = newDate
                            }
                        }
                        
                        GroupManager.addNewGroup(group:thisGroup)
                    }
                    
                    let newestModifiedDate = ConstValue.convertDateFromString(modifiedDate)
                    ManipulateUserDefaults.setNewestGroupRelationModifiedDate(date: newestModifiedDate!)
                    
                    
                } catch {
                    
                    print("JSON error2 in getNewestGroup")
                }
            }
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
        } catch {
            print("JSON error1 in getNewestGroup")
        }
    }
    
    static func getAllGroupId() -> [Int]? {
        do {
            let realm = try Realm()
            let groups = realm.objects(Group.self)
            var ids_group = [Int]()
            for i in 0..<groups.count {
                let id_group = groups[i].id_group
                ids_group.append(id_group)
            }
            return ids_group
            
        } catch {
            print("error in Realm initialization")
        }
        return nil
    }
    
    static func addNewGroup(group:Group) {
        let realm : Realm
        do{
            realm = try Realm()
            try! realm.write {
                realm.add(group, update:true)
            }
        }catch{
            print("error in addnewjob")
        }
    }
    
    static func getAllGroups() -> Results<Group>{
        let realm : Realm
        realm = try! Realm()
        let groups = realm.objects(Group.self)
        return groups
    }
    
    static func deleteAllObject(){
        let realm = try! Realm()
        try! realm.write {
            let allItems = realm.objects(Group.self)
            realm.delete(allItems)
            
        }
    }
    
    static func queryGroupByGroupid(id_group:Int) -> Results<Group> {
        let realm : Realm
        realm = try! Realm()
        let groups = realm.objects(Group.self).filter("id_group = %@",id_group)
        return groups
    }
    
    /**
    内容がなくても空の配列がかえる/countして中身を確かめてから使用すること
    */
    static func getAllGroupsidArray() -> [Int] {
        let groups = GroupManager.getAllGroups()
        var groupsIdArray = [Int]()
        for i in  0..<groups.count {
            let thisId = groups[i].id_group
            groupsIdArray.append(thisId)
        }
        return groupsIdArray
        
    }
    
    /**
     group_idでクエリをかけ、そのオブジェクトのList<User>にappendする
 　　*/
    static func addGroupsMembers(friends: List<User>) {
        let realm: Realm
        realm = try! Realm()
        try! realm.write {
            realm.add(friends, update:true)
        }
    }
    
}

