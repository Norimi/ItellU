//
//  ProfileViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/21.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAuthUI
import FirebaseFacebookAuthUI
import SDWebImage

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileDescriptionLabel: UILabel!
    @IBOutlet weak var acceptedJobTableView: UITableView!
    @IBOutlet weak var logOutBtn: UIButton!
    @IBOutlet weak var loginBtn: UIButton!
    
    var authUI: FUIAuth { get { return FUIAuth.defaultAuthUI()!}}
    let providers : [FUIAuthProvider] = [FUIFacebookAuth()]
    
    @IBAction func logOutBtnTouchUpInside(_ sender: Any) {
        LoginManager.signOut()
    }
    
    @IBAction func logInBtnTouchUpInside(_ sender: Any) {
        let loginViewController = LoginViewController()
        self.present(loginViewController, animated: true, completion: nil)
    }
    
    
    @IBOutlet weak var logInBtnTouchUpInside: UIButton!
    
    var userInfo : [String:Any?] {
        //queryする負荷は考慮する/UserObjcetをuserdefaultにいれることも考える
        get { return ManipulateUserDefaults.getUserInfo()}
    }
    var doingJobList: Results<Job> {
        get { return JobManager.queryDoingJobByReceiver(receiver_id_user: ManipulateUserDefaults.getUserid() ?? "")}
    }
    
    var doneJobList: Results<Job> {
        get { return JobManager.queryDoneJobByReceiver(receiver_id_user: ManipulateUserDefaults.getUserid() ?? "")}
    }
    
    var reportList : Results<Report>? {
        get { return ReportManager.queryReportByIdUser(id_user: ManipulateUserDefaults.getUserid() ?? "") }
    }
    
    var selectedIndex = Int()
    var selected_id_job = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedJobTableView.delegate = self
        acceptedJobTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        //ログイン直後のみデリゲートメソッドよりはやくこちらを読み込む
        if let imageURLString: String = userInfo["photoURL"] as? String {
            if(imageURLString.characters.count > 0){
                let imageURL = NSURL(string:imageURLString) as URL!
                profileImage.sd_setImage(with: imageURL)
            }else {
                let placeHoldURL = DomainManager.DomainKeys.profileImagePlaceholder.rawValue
                let imageURL = NSURL(string:placeHoldURL) as URL!
                profileImage.sd_setImage(with: imageURL)
            }
        }
        
        
        //FB登録でない場合にphotoURLを取得するため自身のデータをremoteから取得する
        //TODO:設計を考える/FB以外からもupload対応するときにまとめて実装
//        let resultHandler = {(user:User)->Void
//            in
//            if let phtoURLString = user.photoURL {
//                if(phtoURLString.characters.count > 0){
//                    ManipulateUserDefaults.setPhotoURL(photoURL: user.photoURL!)                }
//            }
//            
//        }
//        let uid = userInfo["id_user"] ?? ""
//        if(uid != nil){
//            KeliManager.getUserForKeli(uid:uid as! String, resultHandler)
//            let thisUser = UserManager.queryUserById(id_user: uid as! String)
//            print("thisUser", thisUser)
//        }
//        print("uid", uid)
//
//    
        toggleLoginLogoutBtn()
        nameLabel.text = userInfo["name"] as? String ?? ""
        profileDescriptionLabel.text = userInfo["profile"] as? String ?? ""
        acceptedJobTableView.reloadData()
        
    }
    
    func toggleLoginLogoutBtn() {
        
        let loginBool = ManipulateUserDefaults.getLoggedIn()
        if(loginBool){
            logOutBtn.isHidden = false
            loginBtn.isHidden = true
            
        } else {
            logOutBtn.isHidden = true
            loginBtn.isHidden = false
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if(section == 0){
            return doingJobList.count
        } else if (section == 1) {
            return doneJobList.count 
        }
        
        return 0
    }
    
   
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell? = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if !(cell  != nil){
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")
        }

        if(indexPath.section == 0) {
            if(doingJobList.count == 0){
                return cell!
            }

            cell?.textLabel?.text = doingJobList[indexPath.row].title
            let dateString = ConstValue.stringFromDate(date: doingJobList[indexPath.row].modified)
            cell?.detailTextLabel?.text = dateString
        } else if(indexPath.section == 1){
            if(doneJobList.count == 0){
                return cell!
            }
            cell?.textLabel?.text = doneJobList[indexPath.row].title
            let dateString = ConstValue.stringFromDate(date: doneJobList[indexPath.row].modified)
            cell?.detailTextLabel?.text = dateString
        }
        
        
        return cell!
     }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if(indexPath.section == 0){
            selectedIndex = indexPath.row
            selected_id_job = (doingJobList[indexPath.row].id_job)
                    } else if(indexPath.section == 1){
            selectedIndex = indexPath.row
            selected_id_job = (doneJobList[indexPath.row].id_job)
        }
        
        performSegue(withIdentifier: "ShowProfileReport", sender: self)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let reportVC : ProfileReportViewController = (segue.destination as? ProfileReportViewController)!
        reportVC.thisId_job = selected_id_job
    }
  
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = ["  実行中のジョブ", "  終了したジョブ"]
        return title[section]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = ConstValue.globalYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ConstValue.globalPink
        header.textLabel?.font = UIFont(name: "Hiragino Sans W6", size:13)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //表示されるときの最終的な値はここで決定される
        return ConstValue.globalCellHeight * 2/3
    }

}
