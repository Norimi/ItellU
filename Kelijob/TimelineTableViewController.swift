//
//  TimelineTableViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/16.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift
import Firebase
import FirebaseAuthUI
import FirebaseAuth
import FirebaseFacebookAuthUI
import FBSDKCoreKit
import FBSDKLoginKit
import SDWebImage


class TimelineTableViewController: UITableViewController {
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers : [FUIAuthProvider] = [FUIFacebookAuth()]
    let reloadDataInterval: Double = 10
    var jobs : Results<Job> {
        //readonlyとする
        get { return JobManager.getAllObjects()}
    }
    
    var kelis : Results<Keli> {
        
        get { return KeliManager.getAllObjects()}
    }
    
    //TODO:使わないときには空にしたい
    var keliToHandle = Keli()
    //Realmオブジェクトがマルチスレッドに対応していないのでDictionary型を使用
    //TODO:keliToHandleは画面遷移でパスされていき、管理が難しいのでゆくゆくはこちらに統一する
    var keliToHandleDict = [String:Any]()
    var friendsArray = [[String:Any]]()
    
    override func loadView(){
        super.loadView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibDataForTableViewCell()
        //初回起動時に利用規約を表示する
        if(ManipulateUserDefaults.checkEula() == true){
            checkLoggedIn()
        }else{
            let vc: EULAViewController = EULAViewController()
            self.present(vc, animated: true, completion: nil)
        }
        
        let tm = Timer.scheduledTimer(timeInterval: reloadDataInterval, target: self, selector: #selector(reloadDataForTimer), userInfo: nil, repeats: true)
        RunLoop.current.add(tm, forMode: .commonModes)
    }
    
    override func viewWillAppear(_ animated: Bool) {

        checkLoggedIn()
        tableView.reloadData()
        //表示確認:バッジの数字をクリアする
        ManipulateUserDefaults.resetKeliCountForBadge()
        let application = UIApplication.shared
        application.applicationIconBadgeNumber = 0
        print("kelis", kelis)
    }
    
    func reloadDataForTimer (){
        tableView.reloadData()
    }
    
    func setXibDataForTableViewCell(){
        
        let nib = UINib(nibName:"TimelineCell", bundle:nil)
        self.tableView.register(nib, forCellReuseIdentifier: "TimelineCell")
        
    }
    
    @IBAction func unwindAction(unwindSegue:UIStoryboardSegue){
        //CreateJobViewControllerのdismissのためのメソッドをこちらのViewControllerに実装
    }
    
    override func viewDidAppear(_ animated : Bool) {
        //viewDidLoadやviewWillAppearで呼び出すとエラーになる
        super.viewDidAppear(true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return kelis.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //nibが登録されているのでnilで返されることはありません
        let cell : TimelineCell = tableView.dequeueReusableCell(withIdentifier: "TimelineCell", for: indexPath) as! TimelineCell
        
        let thisKeli = kelis[indexPath.row]
        //realmにクエリを投げて帰ってきたオブジェクトを使用
        let thisJobs = JobManager.queryJobById(id_job: thisKeli.id_job)
        cell.selectGroupBtn.addTarget(self, action: #selector(self.selectGroupBtnTouchUpInside(_:id_group:)), for: .touchUpInside)
        cell.selectFriendBtn.addTarget(self, action: #selector(self.selectFriendBtnTouchUpInside(_ :)), for: .touchUpInside)
        cell.acceptBtn.addTarget(self, action: #selector(self.acceptBtnTouchUpInside(_:)), for: .touchUpInside)
        
        

        //"あいてる?""うける"ボタンの表示:keli_to_userが自分の場合かgroupに蹴られた場合
        if(thisKeli.accepted == true){
            //acceptされている
            cell.acceptBtn.isHidden = true
            cell.selectFriendBtn.isHidden = true
            cell.selectGroupBtn.isHidden = true
            
        } else {
            //acceptされていない場合
            //自分宛かグループ宛の場合ボタンを表示
            if(thisKeli.keli_to_userid == ManipulateUserDefaults.getUserid() || thisKeli.keli_to_groupid > 0 ){
                
                //id_keli_beforeがこのid_keliのものがあるかどうかを検索/なければ最新
                let newestKeli: Results<Keli>! = KeliManager.queryKeliByIdKelibefore(id_keli: thisKeli.id_keli)
                if(newestKeli.count == 0){
                    //jobに対してkeliが最新の場合
                    cell.acceptBtn.isHidden = false
                    cell.selectFriendBtn.isHidden = false
                    cell.selectGroupBtn.isHidden = false
                    
                    //表示するときtargetを作成
                    if(thisJobs.count == 0){
                        //ここに入るのはデータの整合性がおかしいです
                        return cell
                    }
                    
                    if(thisJobs[0].id_group > 0){
                        //グループのジョブのKeli（グループ内で個人で回されている場合含む)
                        cell.selectFriendBtn.isHidden = true
                        let id_group_arg = thisJobs[0].id_group
                        //idをボタンに仕込んで渡す
                        cell.selectGroupBtn.setTitle(String(id_group_arg), for: .disabled)
                        cell.selectGroupBtn.tag = indexPath.row

                        
                    } else {
                        //個人宛
                        cell.selectGroupBtn.isHidden = true
                        cell.selectFriendBtn.tag = indexPath.row
                    }


                    cell.acceptBtn.tag = indexPath.row
                    
                } else {
                    //keliが先に続いている場合
                    cell.acceptBtn.isHidden = true
                    cell.selectFriendBtn.isHidden = true
                    cell.selectGroupBtn.isHidden = true
                }
            } else {
                
                //自分宛でもグループ宛でもない蹴りの場合（友達宛の蹴り)
                cell.acceptBtn.isHidden = true
                cell.selectFriendBtn.isHidden = true
                cell.selectGroupBtn.isHidden = true
                
            }
        }
        
        if(thisJobs.count == 0){
            cell.titleLabel.text = "この仕事は削除されています"
            cell.descriptionLabel.text = ""
            cell.acceptBtn.isHidden = true
            cell.selectFriendBtn.isHidden = true
            cell.selectGroupBtn.isHidden = true
            return cell
        }
        
        #if DEBUG
            cell.debug_id_KeliLabel.text = String(thisKeli.id_keli)
        #endif
        
        //結果はひとつしかないはずだが配列で返されるので[0]をとる
        let thisJob = thisJobs[0]
        if let creatorId = thisJob.id_user as String? {
            if((creatorId.characters.count) > 0){
                //TODO:下記値がないときに対応すること
                if let creator = UserManager.queryUserById(id_user: creatorId){
                    if(creator.name != nil){
                        cell.creatorLabel.text = creator.name! + "さんが作成したJob"
                    } else {
                        //ここに入らないように実装しましょう
                        cell.creatorLabel.text = "作成されたJob"
                    }
                }

            }
        }
        
        cell.titleLabel.text = thisJob.title
        cell.descriptionLabel.text = thisJob.job_description
        let thisDate = ConstValue.stringFromDate(date: thisJob.created)
        cell.dateLabel.text = thisDate
        //getActorsはuserが見当たらないと空で返します
        let senderUserName = KeliManager.getActors(keli:thisKeli)[0].name ?? ""
            //keliのsenderが見当たらないのはバグです
//            print("getactors",KeliManager.getActors(keli:thisKeli))
//            print(thisKeli)
//            fatalError("data consistency is not correct")
       
        
        if let senderUserPhoto: String = KeliManager.getActors(keli: thisKeli)[0].photoURL{
            print("senderUserPhoto", senderUserPhoto)
            if(senderUserPhoto.characters.count > 0){
                let photoURL = NSURL(string: senderUserPhoto)
                cell.jobImageView.sd_setImage(with: photoURL as URL!)
            } else {
                let photoURLString = DomainManager.DomainKeys.friendImagePlaceholder.rawValue
                let photoURL = NSURL(string: photoURLString)
                cell.jobImageView.sd_setImage(with: photoURL as URL!)
            }
        }

        
        if(!thisKeli.accepted){
            

            if let destinationUserName = KeliManager.getActors(keli:thisKeli)[1].name {
                cell.actionLabel.text = senderUserName + "さんが" + destinationUserName + "さんへ、あいてる?"
            } else {
                //相手の指定がないKeliの場合
                //group指定があるかどうか
                if(thisKeli.keli_to_groupid > 0){
                    
                    if let groupname = KeliManager.getGroupNameByIdKeli(id_keli: thisKeli.id_keli) {
                        cell.actionLabel.text = senderUserName + "さんが" + groupname + "へ、あいてる?"
                        } else {
                        //グループの指定も友達の指定もない場合
                        cell.actionLabel.text = senderUserName + "さんへ、あいてる?"
                    }
                }
                
            }
            
            //acceptedではないので"うける"押下の用意としてプロパティにセットする
            keliToHandle = thisKeli
            
        }else{
            
            //すでに仕事が受けられたとき
            //グループの仕事でも個人名が入る仕様
            //レポートを検索する
            //TODO:現状レポートを同じセルにはっているが、デザイン的に解決すること
            let report = ReportManager.queryReportByIdKeli(id_keli: thisKeli.id_keli)
            if(report.count > 0){
                if(thisJob.done == true){
                    let uke = senderUserName + "さんがこの仕事を終了しました!"
                    let reportComment = report[0].comment
                    cell.actionLabel.text = uke
                    cell.commentLabel.text = "レポート:\n" + reportComment!
                    
                } else {
                    let uke = senderUserName + "さんがこの仕事を受けました!"
                    let reportComment = report[0].comment
                    cell.actionLabel.text = uke
                    cell.commentLabel.text = "レポート:\n" + reportComment!
                }

            } else {
                //異常系:Reportがない場合
                let uke = senderUserName + "さんがこの仕事を受けました!"
                cell.actionLabel.text = uke
                cell.commentLabel.text = senderUserName + "さんがレポートを作成しています。"
            }
        }
        
        
        let comments: Results<Comment> = CommentManager.queryCommentByIdKeli(id_keli:thisKeli.id_keli)
        if comments.count > 0{
            cell.commentLabel.text = comments[0].comment ?? ""
        }
        
        return cell
    }
    
    //ける ボタン
    func selectFriendBtnTouchUpInside(_ sender : UIButton) {
        keliToHandle = kelis[sender.tag]
        performSegue(withIdentifier: "ShowSelectFriendsView", sender: sender)
    }
    
    func selectGroupBtnTouchUpInside(_ sender : UIButton, id_group: Int) {
        //senderのtagからindexPathを取得する
        //グループの場合はグループメンバーを表示する
        //グループのメンバーをリモートから取得して表示する画面(FriendsInGroupViewController)へ遷移
        let id_group = Int(sender.title(for: .disabled)!)
        let resultHandler = {(_ friendsArray:[[String:Any]]) -> Void
            in
            self.friendsArray = friendsArray
            if(friendsArray.count > 0){
                let this_id_keli = self.kelis[sender.tag].id_keli
                //スレッドを考慮してRealmオブジェクトは使用しない
                self.keliToHandleDict = KeliManager.getAKeliDictByIdKeli(id_keli: this_id_keli)
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ShowFriendsInGroup", sender: nil)
                }
            }
            
        }
        UserManager.getFriendsFromGroup(id_group:id_group!, resultHandler:resultHandler)
        keliToHandle = kelis[sender.tag]
        //performSegue(withIdentifier: "ShowSelectGroup", sender: sender)
    }
    
    
    func acceptBtnTouchUpInside(_ sender : UIButton){
        keliToHandle = kelis[sender.tag]
        performSegue(withIdentifier: "ShowCreateReport", sender: UIButton.self)
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //詳細画面への遷移
        keliToHandle = kelis[indexPath.row]
        let thisKeli = kelis[indexPath.row]
        //realmにクエリを投げて帰ってきたオブジェクトを使用
        let thisJobs = JobManager.queryJobById(id_job: thisKeli.id_job)
        let alert: UIAlertController = UIAlertController(title: "プロバイダに報告", message: "不適切なユーザーやコンテンツが気になる場合は、\nお知らせください。", preferredStyle: .actionSheet)
        let id_user = ManipulateUserDefaults.getUserid()
        
        let reportUser: UIAlertAction = UIAlertAction(title: "表示されているユーザーを報告", style: .destructive) { (alert) in
            let postDict = ["id_user":id_user, "id_friend":thisKeli.keli_from_userid, "id_job":0] as [String : Any]
            do {
                let jsonDict = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
                let urlKey = DomainManager.DomainKeys.reportObjectionable.rawValue
                let url = DomainManager.readDomainPlist(key: urlKey)
                KeliConnection.postMethod(urlString: url, data: jsonDict)
            } catch {
                
            }
        }
        let reportJob: UIAlertAction = UIAlertAction(title: "表示されているジョブを報告", style: .destructive) { (alert) in
            let postDict = ["id_user":id_user, "id_friend":"", "id_job":thisJobs[0].id_job] as [String : Any]
            do {
                let jsonDict = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
                let urlKey = DomainManager.DomainKeys.reportObjectionable.rawValue
                let url = DomainManager.readDomainPlist(key: urlKey)
                KeliConnection.postMethod(urlString: url, data: jsonDict)
            } catch {
                
            }
            print("")
        }
        let cancel: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel) { (alert) in
            print("")
        }
        alert.addAction(reportUser)
        alert.addAction(reportJob)
        alert.addAction(cancel)
        self.present(alert, animated:true, completion:nil)
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier == "ShowCreateReport"){
            
            let createReportVC : CreateReportViewController = (segue.destination as? CreateReportViewController)!
            createReportVC.keli = keliToHandle
        }
        
        if(segue.identifier == "ShowSelectFriendsView"){
            
            let selectFriendsVC: SelectFriendsTableViewController = (segue.destination as? SelectFriendsTableViewController)!
            let id_keli = keliToHandle.id_keli
            let keliDict = KeliManager.getAKeliDictByIdKeli(id_keli: id_keli)
            selectFriendsVC.keliToPass = keliDict
        }
        
        if(segue.identifier == "ShowFriendsInGroup") {
            let frGrVC: FriendsInGroupTableViewController = (segue.destination as? FriendsInGroupTableViewController)!
            frGrVC.transitionType = .keli
            frGrVC.passedKeliDict = keliToHandleDict
            frGrVC.friendsArray = self.friendsArray
        }
    }
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //表示されるときの最終的な値はここで決定される
        return ConstValue.globalTimelineCellHeight
    }
    
}


extension TimelineTableViewController: FUIAuthDelegate {
    
    func checkLoggedIn(){
        self.setupLogin()
        
        FIRAuth.auth()?.addStateDidChangeListener{auth, user in
            if user != nil{
                //サインインしている
            } else {
                //サインインしていない
                self.login()
            }
        }
    }
    
    func setupLogin(){
        
        authUI.delegate = self
        self.authUI.providers = providers
        let kFirebaseTermsOfService = URL(string: "https://itellu-af3d6.firebaseapp.com")!
        authUI.tosurl = kFirebaseTermsOfService
    }
    
    func setupCustomStrings() {
        
        authUI.customStringsBundle = Bundle.main
    }
    
    func login() {
        
//        let authViewController = authUI.authViewController()
//        self.present(authViewController, animated: true, completion: nil)
        let loginViewController = LoginViewController()
        self.present(loginViewController, animated: true, completion: nil)
        
    }
    
    func authPickerViewController(forAuthUI authUI: FUIAuth) -> FUIAuthPickerViewController {
        let authVC = AuthTableViewController(authUI:authUI)
        return authVC
    }
    
    //FUIAuthDelegateの必須メソッド
    public func authUI(_ authUI: FUIAuth, didSignInWith user: FIRUser?, error: Error?){
        /**
         # ログイン完了/未完了に関わらずログインUIのViewControllerがdismissされるとき呼ばれている
         
         ## ログイン未完了
         - 何もせず抜ける
         
         ## ログイン完了/場合分け
         　4つの場合がある。
         - Emailでログイン:IDのみ保存する
         - FBでログイン:全ての情報を保存する
         - FB後にEmailでログイン:サーバーを確認してなにもしない
         - Email後にFBでログイン:IDを問い合わせてFBの情報を入れる/FBIDがあるかどうかを確認する
         
         ## 処理
         - サーバーにデータを格納する
         - 結果をUserDefaultに保存する
         
         ## ID
         - idはFirebaseのUIDを使用する
         */
        
        LoginManager.parseUserInfo()
        //LoginManager.setUserInfoForFBAuth()
        
    }
    
    
}
