
//
//  KelijobTests.swift
//  KelijobTests
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import XCTest
import RealmSwift
import Firebase
import FirebaseAuth

@testable import Kelijob

//https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/04-writing_tests.html#//apple_ref/doc/uid/TP40014132-CH4-SW1

class KelijobTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        //JobManager.deleteAllObject()
    }
    
    //****************** test UserDefaults *************************
    func testGetUserid() {
        print("testgetuserid", ManipulateUserDefaults.getUserid())
    }
    
    func testDeleteUserid() {
        ManipulateUserDefaults.deleteUserid()
    }

    func testDeleteUserinfo() {
        ManipulateUserDefaults.deleteUserinfo()
    }
    
    
    func testGetUserinfo() {
        let dict = ManipulateUserDefaults.getUserInfo()
        print("name", dict["name"] as! String? ?? "")
        print("id", dict["id_user"] as! String? ?? "")
        print("email", dict["email"] as? String ?? "")
        print("photoURL", dict["photoURL"] as? String ?? "")
        print("profile", dict["profile"] as? String ?? "")
    }
    
    func testDeleteUserInRealm() {
        UserManager.deleteUserFromId(id_user: "ztzEHSjUhTc0wW7ouKqKNjUytvk2")
        ManipulateUserDefaults.deleteUserinfo()
    }
    
    /**
     友達申請/受託ロジックのテスト
     id_user:3とする
     id_user:5に対して/UIを使用して友達申請する→DB確認
     id_user:5のモックデータで友達を受託する
     id_user:5での友達表示を確認する
     id_user:3での友達表示を確認する
     
     リモートでid_user:102と103のUserを作成する
     id_user:102とする
     id_user:103に対して/UIを使用して友達申請する→DB確認
     id_user:103のモックデータで友達を受託する
     id_user:103での友達表示を確認する
     id_user:103のRealmを確認する
     id_user:102での友達表示を確認する
     id_user:102のRealmを確認する
     
     　　*/
    func test_UI_ApplyFriend() {
        ManipulateUserDefaults.setUserid(id_user: "101")
        //UIにて友達申請を行った
        //申請後の表示を修正
        
    }
    
    func testUserObjects() {
        print("testUserObjects",UserManager.getAllFriends())
    }
    
    
    func testDeleteAllUsers() {
        UserManager.deleteAllObject()
    }
    
    
//    func testFirebase(){
//        let rootRef = FIRDatabase.database().reference()
//        //test/one/title,description,timestamp
//        let jsonObject: [String: Any?] = ["test2":"test"]
//        //let valid = try! JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
//        rootRef.childByAutoId().setValue(jsonObject)
//        
//    }
//    
//    func testChildNode(){
//        let rootRef = FIRDatabase.database().reference()
//        let conditionRef = rootRef.child("test")
//        conditionRef.observe(.value) { (snap: FIRDataSnapshot) in
//            print("ノードの値が変わりました！: \((snap.value as AnyObject).description)")
//            
//        }
//        conditionRef.setValue("newValue 2 from Xcode")
//    }
//    
//    func testChangeValue() {
//        let rootRef = FIRDatabase.database().reference()
//        let conditionRef = rootRef.child("test")
//        conditionRef.setValue("newValue from Xcode")
//        
//    }
//    
    func testSetUserid(){
        ManipulateUserDefaults.setUserid(id_user: "103")
    }
//
//    func testResetUserid() {
//        //ManipulateUserDefaults.setUserid(id_user: [])
//    }
    
    //ログイン
    //サインアウトしてログインチェックを行う
    //ログインしていないと判断されればOK
    enum TestError: Error {
        case logoutTest(message: String)
    }
    
    func testSignOutAndLoginCheck() {
        
        LoginManager.signOut()
        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
                XCTAssertThrowsError(TestError.logoutTest(message:"signed in after sign out"))
                
            } else {
                //サインインしていない
                XCTAssert(true)
                
            }
        }
    
    }
    
    //userdefaultを消去した状態で実行する
    
    //emailのみ登録のあるアカウントでログインする
    //norimi@email.com
    
    //nilの項目が多いkeli,user,jobのデータを作成する
    //確認後データ消去する
    
    //phpスクリプト確認用
    //apply_friendに値をpostする
    func testApplyFriend() {
     
        let uid = ManipulateUserDefaults.getUserid()
        let id_friend = String(1)
        let postDict = ["id_user":uid, "id_friend":id_friend]
        let jsonData = try! JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.applyFriend.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        KeliConnection.postMethod(urlString: url, data: jsonData);
        
    }
    
    func testGetApply() {
        
        let uid = ManipulateUserDefaults.getUserid()
        let postDict = ["id_user":uid]
        let jsonData = try! JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.getApply.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        //実際はエラーハンドリングとユーザーデータ取得を行う
        KeliConnection.postMethod(urlString: url, data: jsonData);
        
    }
    
    //申請受諾
    //relationのテーブルはローカルに持たない設定で/idのみ通信後に判明しているとして
    //レスポンスとしてUserデータを返す
    //やはりget_all/newest_fiendも必要ですね
    func testAcceptApplication() {
        
        //データと異なる関係性(id_friend)で実装中
        let id_relation = 3
        let id_friend = String(5)
        let postDict = ["id_relation":id_relation, "id_friend":id_friend, "id_user":ManipulateUserDefaults.getUserid()] as [String : Any]
        let jsonData = try! JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.acceptApplication.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        KeliConnection.postMethod(urlString: url, data:jsonData)
    }
    
    func testGetNewestModifiedUser() {
        
        //DBから最新の日付を取得する
        //これはNSDateFormatterによってconvertされた後の値
//        let resultString: String? = UserManager.getNewestModifiedDate()
//        print("resultString in testGetNewestModifedUser", resultString)
        
        //独自に最新の日付を取得する
//        let allUsers = UserManager.getAllFriends()
//        print(allUsers)
//        let newestModifiedUser = allUsers.sorted(byProperty:"modified", ascending: false)
//        print("newestModifiedDate", String(describing: newestModifiedUser[0].modified))
//        let strFromFormatter = ConstValue.stringFromDate(date: newestModifiedUser[0].modified)
//        
//        XCTAssertEqual(resultString, strFromFormatter)
        
        
    }
    
    func testGetNewestFriends() {
        
        //userのmodifiedでRelationを検索することになる...
        //最新のrelationを同時に取得してuserdefaultへ入れる
        let uid = ManipulateUserDefaults.getUserid()
        let thisDate = ManipulateUserDefaults.getNewestRelationModifiedDate()
        let dateString = ConstValue.stringFromDate(date: thisDate!)
        let postDict = ["uid":uid, "modified":dateString]
        let jsonData = try! JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.getNewestFriends.rawValue
        let url = DomainManager.readDomainPlist(key:urlKey)
        KeliConnection.postMethod(urlString: url, data: jsonData)
        
    }
    
    func testGetNewestFriendsAPI() {
        UserManager.downloadNewestFriends()
    }
    
    
    func testSetNewestModifiedDate() {
        let dateStr = "2000-01-01 00:00:00"
        let date = ConstValue.convertDateFromString(dateStr)
        ManipulateUserDefaults.setNewestRelationModifiedDate(date: date!)
        let newDate = ManipulateUserDefaults.getNewestRelationModifiedDate()

    }
    
    //deprecated:テストコードから完了ハンドラの動作確認できず
    func testDLNewestFriends() {
        
        UserManager.downloadNewestFriends()
    }
    
    func testGetApplyWithHandler() {
        let resultFriendArray = Array<ApplyingUser>()
        UserManager.getFriendApplication(reloadDataHandler: {(resultFriendArray)-> Void in print("inside reload data handler")})
    }
    
    func testGetRelationNewestModifiedDate () {
        let newDate = ManipulateUserDefaults.getNewestRelationModifiedDate()
        print("testGetRelationNewestModifiedDate", String(describing:newDate))
    }
    
    
    
    //********* Create Group ************
    func testCreateGroup() {
    
        let urlKey = DomainManager.DomainKeys.createGroup.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        let dataDict = ["name":"group1", "description":"", "id_user":"ZFDQk8tTgVbNgIsLUqOZf5FfE3B3"];
        let jsonData = try! JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
        //completionHandler内で返って来たidを取得し、次のページに渡す
        KeliConnection.postMethod(urlString: url, data: jsonData)
    }
    
    func testCreateRelation() {
    
        //友達を選択するたびに通信する　or　DBに?まとめておいて送信、適宜消去する
        //使い方注意:relation作成時groupのときはid_friendに0を入れないとエラー
        let uid = ManipulateUserDefaults.getUserid()
        let id_group = 3
        let dataDict:[String:Any] = ["id_user":uid, "id_group":id_group, "id_friend":"0"]
        let jsonData = try! JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.createRelation.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        KeliConnection.postMethod(urlString: url, data: jsonData)
        
    }
    
    //************ Manipulate Group *****************
    func testGetNewestGroup() {
        
        let uid = ManipulateUserDefaults.getUserid()
        let newestModified: Date = ManipulateUserDefaults.getNewestGroupRelationModifiedDate()!
        let dateString = ConstValue.stringFromDate(date: newestModified)
        let dict:[String:Any] = ["uid":uid, "modified":dateString]
        let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        //let jsonData = try! JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.getNewestGroup.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        KeliConnection.postMethod(urlString: url, data: jsonData)
        
    }
    
    func testDownloadGetNewestGroup() {
        GroupManager.downloadNewestGroups()
    }
    
    func testGetAllGroups() {
        let groups = GroupManager.getAllGroups()
        print(groups)
    }
    
    func testSetGroupNewestModified() {
        let dateStr = "2000-01-01 00:00:00"
        let date = ConstValue.convertDateFromString(dateStr)
        ManipulateUserDefaults.setNewestGroupRelationModifiedDate(date: date!)
    }
    
    
    func testGetFriendsFromGroup() {
        let resultHandler = {(_ data:[[String:Any]]) -> Void
            in
            print(data)
        }
        UserManager.getFriendsFromGroup(id_group:3, resultHandler:resultHandler)
    }
    
    //********* Manipulate Friends ******************
    func testGetAllFriends() {
        let friends = UserManager.getAllFriends()
        print(friends)
    }
    
    func testDeleteAllFriends() {
        FriendsManager.deleteAllObject()
    }
    
    //********* Manipulate Comments *******************
    func testDeleteAllComments (){
        KeliManager.deleteAllObjects()
        CommentManager.deleteAllObjects()
    }
    
    //********* Manipulate Userdefaults **************
    func testSetPhotoURL() {
        let photoString = "http://noriming2017.xsrv.jp/Kelijob/test_profile/06.jpg"
        ManipulateUserDefaults.setPhotoURL(photoURL: photoString)
    }
    
    //userのmodifiedから最新のものをidで洗い出してそれ以上の日付があるものをrelationから検索する
    //受諾された申請に基づいてUserを取得する
    //関係を洗い出し関連のあるユーザーを取得する
    //最新データを取得するバージョンを作成する

    func testGetAllObjects() {
        let jobs = JobManager.getAllObjects()
        print(jobs)
        let kelis = KeliManager.getAllObjects()
        print(kelis)
        let users = UserManager.getAllFriends()
        print(users)
        let reports = ReportManager.getAllObjects()
        print(reports)
    }
    
    //一件のJobDataを作成する
    //差分から最新データを取得できるか試す
    func testGetNewestJob() {
  
        
        KeliManager.deleteAllObjects()

        JobManager.deleteAllObject()
        UserManager.deleteAllObject()
        ReportManager.deleteAllObjects()
        
        let newJob = Job()
        let i = 125
        newJob.id_job = i
        //newJob.id_user = i
        newJob.title = String(i) + "の仕事"
        
        let str = "2017-01-13 05:38:06"
        let date: Date = ConstValue.convertDateFromString(str)!
        newJob.modified = date
        
        newJob.job_description = String(i) + "という仕事になります。生産活動は、いつの時代でも、何らかの表象体系（意味づけの体系）と関わりがある[4]。人間が行っている現実の生産行為とそれを包括するいる表象とは、バラバラではなく、一体として存在する[4]。いいかえると、何らかの生産活動があれば、それを解釈し表現する言葉が伴うことになり、こうした言葉には特定の歴史や世界像（世界観）が織り込まれていると考えられている[4]"
        
        JobManager.addNewJob(job:newJob)
        JobManager.downloadNewestJobs()
        let job = JobManager.getAllObjects()
        print(job.last)
        //このテストはcompletionHandlerが待てないので失敗する
        //XCTAssertTrue((job.last?.modified!)! > date, "expected process")

    }
    
    func testDonloadNewestReport() {
        
        //id_jobsがある状態でテストすること
        ReportManager.downloadNewestReports()
    }
    
//    func testGetNewsetModifiedData() {
//        //データが空のときに落ちないことを確認
//        let date = JobManager.getNewestModifiedDate()
//    }
//    
//    
//    func testDateFromString() {
//        let str = "2017-01-13 05:38:06"
//        let date: Date = ConstValue.convertDateFromString(str)!
//        XCTAssertEqual(str, ConstValue.stringFromDate(date: date))
//        
//    }
//    
    func testFormatter() {
        
        let str = "2017-01-13 05:38:06"
        let format = "YYYY-MM-DD HH:mm:ss"
        let formatter = DateFormatter()
        let date0 = formatter.date(from: str)
        formatter.dateFormat = format
        //formatter.timeZone = NSTimeZone(name: "ja_JP") as TimeZone!
        print("date0 in dateFormatter", String(describing: date0))
        //formatter.locale = NSLocale(localeIdentifier: "ja_JP") as Locale!
        let date = formatter.date(from: str)
        print("date in dateFormatter", String(describing: date))
        print(String(describing: date))
        if let result = date {
           
            print("result in testFormatter",result)
        }
        let newDate = formatter.string(from: date!)
        print("new date", String(describing:newDate))
    }
    
    
    func testRealmMigrate(){
        RealmManager.migrateRealm()
    }
    
    func testDeleteRealmFile(){
        //ファイルを削除して作り直しマイグレーションを行う
        let config = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
        Realm.Configuration.defaultConfiguration = config
    }
    
    func testGetAllKelis() {
        print("testGetAllKelis",KeliManager.getAllObjects())
    }
    
//    func testCreate100Jobs(){
//        
//        var jobs = JobManager.getAllObjects()
//        if(jobs.count > 99){
//            //すでにデータがあるときは消去する
//            testDeleteAllJobs()
//        }
//        for i in 0..<100{
//            
//            let newJob = Job()
//            newJob.id_job = i
//            //newJob.id_user = i
//            newJob.title = String(i) + "の仕事"
//            newJob.modified = Date()
//            newJob.job_description = String(i) + "という仕事になります。生産活動は、いつの時代でも、何らかの表象体系（意味づけの体系）と関わりがある[4]。人間が行っている現実の生産行為とそれを包括するいる表象とは、バラバラではなく、一体として存在する[4]。いいかえると、何らかの生産活動があれば、それを解釈し表現する言葉が伴うことになり、こうした言葉には特定の歴史や世界像（世界観）が織り込まれていると考えられている[4]"
//
//            JobManager.addNewJob(job:newJob)
//            
//            
//        }
//        
//        jobs = try! Realm().objects(Job.self)
//        print(jobs)
//        XCTAssertEqual(jobs.count, 100)
//        
//    }
    
    func testDeleteRelation() {
        
        
        let id_relation = 15
        let postDict = ["id_relation":id_relation]
        
        let jsonDict = try! JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
        let urlKey = DomainManager.DomainKeys.deleteRelation.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        KeliConnection.postMethod(urlString: url, data: jsonDict)
        
        
    }
        
    func testDeleteAllJobs(){
        
        JobManager.deleteAllObject()
        let jobs = JobManager.getAllObjects()
        XCTAssertEqual(jobs.count, 0)
    }
    

//    func testCreate100Friends(){
//   
//        //結果:10000オブジェクトでは8.449seconds
//        var friends = UserManager.getAllFriends()
//        if(friends.count > 99){
//            UserManager.deleteAllObject()
//        }
//        
//        for i in 0..<100{
//            
//            
//            let newUser = User()
//            newUser.name = String(i) + "美"
//            newUser.id_user = String(i)
//            newUser.profile = "株式会社" + String(i) + "に勤務"
//            let str = "2017-01-16 05:38:06"
//            let date = ConstValue.convertDateFromString(str)
//            newUser.created = date!
//            newUser.modified = date!
//            UserManager.addNewFriends(friend:newUser)
//            let thisId = newUser.id_user
//            let thisFr = Friends()
//            thisFr.id_user = thisId
//            FriendsManager.addNewId(thisFr)
//            
//            
//        }
//        friends = try! Realm().objects(User.self)
//        print(friends)
//        XCTAssertEqual(friends.count, 100)
//    }
    

    
    
//    func testCreateGroups(){
//        
//        GroupManager.deleteAllObject()
//        
//        let friends = UserManager.getAllFriends()
//        let groupNumber = 10
//        for i in 0..<groupNumber {
//            let newGroup = Group()
//            newGroup.name = String(i) + "チーム"
//            newGroup.id_group = i
//            GroupManager.addNewGroup(group:newGroup)
//        }
//        
//        let groups = GroupManager.getAllGroups()
//        print(groups.count)
//        //let friend = friends[i]
//        
//        for i in 0..<groups.count{
//            
//            switch groups[i].id_group {
//            case  0:
//                for i in 0..<10 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[0].group.append(fr)
//                        groups[0].name = "ゼロから十"
//                    }
//                }
//                
//            case 1:
//                for i in 10..<20 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[1].group.append(fr)
//                        groups[1].name = "十から二十"
//                    }
//                }
//                
//            case 2:
//           
//                for i in 20..<30 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[2].group.append(fr)
//                        groups[2].name = "二十から三十"
//                    }
//                }
//            case 3:
//             
//                for i in 30..<40 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[3].group.append(fr)
//                        groups[3].name = "三十から四十"
//                    }
//                }
//                
//            case 4:
//               
//                for i in 40..<50 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[4].group.append(fr)
//                        groups[4].name = "四十から五十"
//                    }
//                }
//                
//            case 5:
//               
//                for i in 50..<60 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[5].group.append(fr)
//                        groups[5].name = "五十から六十"
//                    }
//                }            case 6:
//              
//                for i in 60..<70 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[6].group.append(fr)
//                        groups[6].name = "六十から七十"
//                    }
//                }
//            case 7:
//            
//                for i in 70..<80 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[7].group.append(fr)
//                        groups[7].name = "七十から八十"
//                    }
//                }
//            case 8:
//              
//                for i in 80..<90 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[8].group.append(fr)
//                        groups[8].name = "八十から九十"
//                    }
//                }
//            case 9:
//              
//                for i in 90..<100 {
//                    let fr = friends[i]
//                    try! Realm().write{
//                        groups[9].group.append(fr)
//                        groups[9].name = "九十から百"
//                    }
//                }            default:
//                print("")
//            }
//            
//            
//        }
//        
//         //}
//        print(GroupManager.getAllGroups())
//        
//    }
    
    func testDeleteKelis(){
        KeliManager.deleteAllObjects()
    }

    func testDeleteAllData() {
        KeliManager.deleteAllObjects()
        JobManager.deleteAllObject()
        UserManager.deleteAllObject()
        ReportManager.deleteAllObjects()
        CommentManager.deleteAllObjects()
        GroupManager.deleteAllObject()
        FriendsManager.deleteAllObject()
    }
    
//
////    func testCreateKelis(){
////        
////        KeliManager.deleteAllObjects()
////        
////        //ユーザーとJOBを登録してから実行すること
////        for i in 0..<10 {
////            let newKeli = Keli()
////            newKeli.id_keli = i
////            newKeli.id_job = Int(arc4random() % 10)
////            newKeli.keli_from_userid = String(arc4random_uniform(10))
////            newKeli.keli_to_userid = String(arc4random_uniform(10))
////
////            KeliManager.addNewKeli(keli:newKeli)
////        
////        }
////        
////        let kelis = KeliManager.getAllObjects()
////        XCTAssertEqual(kelis.count, 10)
////        print(kelis)
////        
////    }
//    
////    func testCreateWhiteKelis(){
////        
////        KeliManager.deleteAllObjects()
//// 
////        for i in 0..<1000 {
////            let newKeli = Keli()
////            newKeli.id_keli = i
////            KeliManager.addNewKeli(keli:newKeli)
////        }
////        
////        let kelis = KeliManager.getAllObjects()
////        XCTAssertEqual(kelis.count, 1000)
////        print(kelis)
////        
////    }
////    
////    func testCreateComments(){
////        //1000件作成してランダムなidをふる
////        CommentManager.deleteAllObjects()
////        
////        for i in 0..<100 {
////            let newComment = Comment()
////            newComment.comment = String(i) + "をやってくれる人募集中ですよ"
////            //id_keliとは本来1対1
////            //同時生成させること
////            //arc4randomの仕様確認
////            newComment.id_keli = i
////            newComment.id_user = Int(arc4random() % 99)
////            newComment.id_job = Int(arc4random() % 99)
////            CommentManager.addNewComment(comment:newComment)
////            print(newComment)
////        }
////        
////    }
//    
//    //createKeliを実行してから行うこと
////    func testCreateReports(){
////        
////        
////        ReportManager.deleteAllObjects()
////        
////        for i in 0..<80 {
////            let report = Report()
////            report.id_report = i
////            
////            //keliのacceptedのjobidがかぶっていないか?
////            //jobからkeliを参照し返した方がはやそう
////            report.id_keli = Int(arc4random() % 79)
////            report.comment = "わたしにまかせてね⭐︎"
////            //いまあるkeliからid_jobとuserを取得
////            let thisKeli = KeliManager.getObjectsByKeliId(id_keli: report.id_keli)
////            report.id_user = thisKeli[0].keli_to_userid
////            let thisKeliJobId = KeliManager.returnJobIdByIdKeli(id_keli: thisKeli[0].id_keli)
////            report.id_job = thisKeliJobId
////            let thisJob = JobManager.queryJobById(id_job: thisKeliJobId)
////            let realm = try! Realm()
////            //jobにreceiverを設定する
////            let keliToUserid = thisKeli[0].keli_to_userid
////            try! realm.write{
//////                thisJob[0].receiver_id_user = keliToUserid
//////                thisJob[0].modified = Date()
////            }
////            
////            //keliにacceptedを設定する
////            //keliのid_userをreportに設定する
////            try! realm.write{
////                thisKeli[0].accepted = true
////                thisKeli[0].keli_to_userid = report.id_user
////            }
////            
////            //対応するkeliをacceptedに設定する
////            //JobManager.updateReceiveridForTest(receiver_id_user: report.id_user, id_job: report.id_job)
////            //KeliManager.changeKeliToUserIdForTest(id_keli: report.id_keli, keli_to_userid: report.id_user)
////            //KeliManager.setAcceptedByIdkeli(id_keli: report.id_keli)
////
////            report.created = Date()
////            ReportManager.addNewObject(object:report)
////            print("report in testCreateReports %@",report)
////            
////            let allKelis = KeliManager.getAllObjects()
////            print(allKelis)
////        }
////        
////    }
//    

//    }
//    
//    func testPrintReports(){
//        let reports = ReportManager.getAllObjects()
//        print(reports)
//    }
//    
    
//    func testCreateDoneReports(){
//        
//        ReportManager.deleteAllObjects()
//        
//        for i in 0..<10 {
//            
//            let report = Report()
//            report.id_report = i
//            report.id_job = Int(arc4random() % 99)
//            report.id_keli = Int(arc4random() % 99)
//            report.id_user = String(arc4random_uniform(10))
//            report.comment = "終わったよ⭐︎"
//            report.done = true
//            //対応するkeliをacceptedに設定する
//            KeliManager.setAcceptedByIdjob(id_job: report.id_job, keli_to_userid: report.id_user)
////            JobManager.updateReceiveridForTest(receiver_id_user: report.id_user, id_job: report.id_job)
//            report.modified = Date()
//            ReportManager.addNewObject(object:report)
//            print("report in testCreateDoneReports %@",report)
//            
//            
//        }
//    }
//    
    func testSendJobReport(){

        let reportString: String? = "レポート本文3"
        
        let newData: [String : Any?] = ["id_user": ManipulateUserDefaults.getUserid(),"id_job": 1, "id_keli": 2, "comment": reportString, "image": "imageurl"]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: newData, options: .prettyPrinted)
            //return jsonData
            let urlKey = DomainManager.DomainKeys.createReport.rawValue
            let url = DomainManager.readDomainPlist(key:urlKey)
            
            KeliConnection.postMethod(urlString:url, data:jsonData)
            
        }catch {
            
            fatalError("error in creating JSON data")
        }
    }
    
//    func testCreateUsersInRemoteDB(){
//        
//        let i = 6
//            
//            //let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
//            //DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
//                //print( "1分後の世界" )
//        
//            //})
//            
////            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
////            })
////
//                let uid = String(i)
//                let name = String(i)+"美"
//                let profile = String(i) + "番目の登録者"
//                let email = String(i) + "@gmail.com"
//                let photoURL = String(i)
//                let userDict : [String:Any?] = ["uid":uid, "name":name, "email":email, "photoURL":photoURL]
//        
//                do{
//                    
//                    let jsonData = try JSONSerialization.data(withJSONObject:userDict, options:.prettyPrinted)
//                    let urlKey = DomainManager.DomainKeys.setUserInfo
//                    let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
//                    KeliConnection.postMethod(urlString:url, data:jsonData)
//            
//                
//                    
//                } catch {
//                    
//                    print("error in JSONSerialization")
//                }
//
//    }
    
//    func testDownloadUserDataFromRemote() {
//        //UserManager.downloadDataFromRemote()
//    }
//
//    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }
//    
}
