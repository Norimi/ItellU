//
//  AppDelegate.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/13.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import Firebase
import RealmSwift
import UserNotifications
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    var ref: FIRDatabaseReference!
    //タイムラインのviewWillAppearで呼び出しているので長めに設定
    let timeIntervalSec: Double = 60

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //Realmのスキーマバージョン指定
        //開発時にこちらでマイグレートします
        RealmManager.migrateRealm()
        //background fetchの登録
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)

        //Notificationの設定
        if #available(iOS 10.0, *) {
            //forTypesは.alertと.soundと.badgeがあります。
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options:[.alert, .sound, .badge]) { (granted, error) in
                if granted {
                    debugPrint("Notification許可")
                    let center = UNUserNotificationCenter.current()
                    UIApplication.shared.registerForRemoteNotifications();
                    center.delegate = self
                }
            }
            
        }
        
        //iOS9以下に対応する場合
        //デリゲートメソッドも実装すること
//        let apnsTypes : UIUserNotificationType = [.badge, .sound, .alert]
//        let notiSettings = UIUserNotificationSettings(types: apnsTypes, categories: nil)
//        application.registerUserNotificationSettings(notiSettings)
//        application.registerForRemoteNotifications()
        
        
        //Firebaseにconfigureする
        FIRApp.configure()
        

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(self.tokenRefreshNotification),
            name: NSNotification.Name.firInstanceIDTokenRefresh,
            object: nil)
        
        let refreshedToken = FIRInstanceID.instanceID().token()
        print("refreshedToken", refreshedToken)
        if let id_user = ManipulateUserDefaults.getUserid(){
            let postDict = ["id_user":id_user, "instanceID":refreshedToken]
            do {
                let jsonDict = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
                let urlKey = DomainManager.DomainKeys.insertToken.rawValue
                let url = DomainManager.readDomainPlist(key: urlKey)
                KeliConnection.postMethod(urlString: url, data: jsonDict)
            } catch {
                
            }
        }
        /**
         このアプリのデータ管理
         最新のJob,User,Keli,ReportをダウンロードしてRealmに追加したものを使用します。
         それぞれがうまく紐づいているか注意してください。
         下記メソッドにより、Realmから最新のmodifiedを取得してリモートサーバーに問い合わせ最新データを取得しRealmに挿入しています。
 　　　　*/
        //起動時DL用
        KeliConnection.downloadNewestDataInInterval()
        //timeIntervalSecに一回用
        downloadAllRequiredData()
        //tabbarとnavigationBarの設定
        UINavigationBar.appearance().barTintColor = ConstValue.globalDeepGreen
        //バッジ表示のためのオーソライズ


        return true
    }
    
    func application(_ application: UIApplication,
                     didRegister notificationSettings: UIUserNotificationSettings) {
        if notificationSettings.types != .none {
            application.registerForRemoteNotifications()
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                         willPresent notification: UNNotification,
                                         withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void){
        setNumberBadge()
        completionHandler([UNNotificationPresentationOptions.sound , UNNotificationPresentationOptions.alert , UNNotificationPresentationOptions.badge])
    }
    
    //push通知にアクションしたときに呼ばれる
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func setNumberBadge() {
        ManipulateUserDefaults.setKeliCountForBadge(num: 1)
        let num = ManipulateUserDefaults.getKeliCountForBadge()
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = num!
    }
    
    func application(_ application: UIApplication,
                              didFailToRegisterForRemoteNotificationsWithError error: Error){
        
    }
    
    /**
     トークン生成をモニタリング
     トークンが生成されると kFIRInstanceIDTokenRefreshNotification が呼び出されるため、そのコンテキストで [[FIRInstanceID instanceID] token] を呼び出すことで、利用可能な現在の登録トークンに 確実にアクセスできます。
    */
    
    // デバイストークン取得時の処理
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let tokenText = deviceToken.map { String(format: "%.2hhx", $0) }.joined()
        print("deviceToken = \(tokenText)")
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.unknown)
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
            if let id_user = ManipulateUserDefaults.getUserid(){
                let instanceID = refreshedToken
                let postDict = ["id_user":id_user, "insntanceID":instanceID]
                do {
                   let jsonDict = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
                    let urlKey = DomainManager.DomainKeys.insertToken.rawValue
                    let url = DomainManager.readDomainPlist(key: urlKey);
                    KeliConnection.postMethod(urlString: url, data: jsonDict)
                } catch {
                    
                }
            }
            
        }
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    

    /**
     タイマーを使用して最新データを60秒に一度取得しつづける
    */
    func downloadAllRequiredData() {
        
        //最新データをダウンロードする
        let sel = #selector(KeliConnection.downloadNewestDataInInterval)
        //タイプメソッドのターゲットには.selfをつける
        let tm = Timer.scheduledTimer(timeInterval: timeIntervalSec, target: KeliConnection.self, selector: sel, userInfo: nil, repeats: true)
        RunLoop.current.add(tm, forMode: .commonModes)
    }
    
    //Facebook認証時にコールされる（終了時ではない)
    //https://github.com/firebase/FirebaseUI-iOS/blob/master/FirebaseAuthUI/README.md
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as! String?
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            
            return true
        }
        
        return false
    }
    
    
    func application(_ application: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void){

        KeliManager.getNewestDataForPush()
        completionHandler(UIBackgroundFetchResult.newData)
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

