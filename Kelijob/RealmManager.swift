//
//  RealmManager.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/17.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class RealmManager {
    
    //https://realm.io/docs/swift/latest/#migrations
    static func migrateRealm(){
        
        let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in
            //Leave the block empty
        }
        Realm.Configuration.defaultConfiguration = Realm.Configuration(schemaVersion: 1, migrationBlock: migrationBlock)

        
        let config = Realm.Configuration(
            schemaVersion: 47,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 47) {
                    print("oldSchemaVersion", oldSchemaVersion)
                }
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    static func deleteRealmFiles() {
        
        autoreleasepool {
            // all Realm usage here
        }
        let realmURL = Realm.Configuration.defaultConfiguration.fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("log_a"),
            realmURL.appendingPathExtension("log_b"),
            realmURL.appendingPathExtension("note")
        ]
        for URL in realmURLs {
            do {
                try FileManager.default.removeItem(at: URL)
            } catch {
                // handle error
            }
        }

    }
    
 
    /**
     # Realmに保存しているデータを全て消去する
 　　*/
    static func deleteAllData() {
        
        KeliManager.deleteAllObjects()
        JobManager.deleteAllObject()
        UserManager.deleteAllObject()
        ReportManager.deleteAllObjects()
        CommentManager.deleteAllObjects()
        GroupManager.deleteAllObject()
        FriendsManager.deleteAllObject()
    }
    
}
