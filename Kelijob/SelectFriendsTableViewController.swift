//
//  FriendsGroupTableViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/17.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

/**
 この画面を経由する場合:JOB作成時、Keli作成時
 */
class SelectFriendsTableViewController: UITableViewController {
    
    /**
    ## keli作成時とjob作成時からランディングする
    ### 選択後の挙動が異なる
     - job作成の場合はCreateJobVCに戻る
     - keliの場合はKeliConfirmVCへ遷移
    */
    enum TransitionType {
        case keli
        case job
    }
    
    var transitionType = TransitionType.keli
    
    //target グループ or 友達
    enum KeliType {
        case group
        case friend
    }
    var keliType = KeliType.friend

    var keliToPass = [String:Any]()
    //var selectedKeli = Keli()
    var id_friend_toPass: String = ""
    var id_group_toPass: Int = 0
    var friend_name_toPass: String = ""
    var group_name_toPass: String = ""
    
    var friends: Results<User> {
        get { return UserManager.getAllFriends() }
    }
    var groups: Results<Group>{
        get { return GroupManager.getAllGroups() }
    }
    var selectedFriend = User()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibForCell()
    }
    
    /** KeliConfirmViewControllerからバックボタンで戻ってきたとき対応できないのでいったん消去
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        keliToPass = [String:Any]()
        id_friend_toPass = "0"
        friend_name_toPass = ""
        group_name_toPass = ""
    }
   */
    
    func setXibForCell() {
        let nib = UINib(nibName: "FriendsGroupCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FriendsGroupCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //グループと友達個人に分けて2とする
        return 3
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 {
            return friends.count
        } else if section == 0 {
            return groups.count
        } else if section == 2 {
            return 1
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        
        if indexPath.section == 1 {
            //友達セクション
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            for subview in cell.contentView.subviews{
                subview.removeFromSuperview()
            }
            cell.addSubview(cell.nameLabel)
            cell.addSubview(cell.profileLabel)
            cell.addSubview(cell.jobInProgressLabel)
            cell.addSubview(cell.fbImageView)
            let thisFriend = friends[indexPath.row]
            cell.nameLabel.text = thisFriend.name
            cell.profileLabel.text = thisFriend.profile
            if let photoURLString = thisFriend.photoURL {
                if(photoURLString.characters.count > 0 ){
                    let imageUrl = NSURL(string: thisFriend.photoURL!)
                    cell.addSubview(cell.fbImageView)
                    cell.fbImageView.sd_setImage(with: imageUrl as URL!)
                } else {
                    cell.addSubview(cell.fbImageView)
                    cell.fbImageView.sd_setImage(with: NSURL(string:DomainManager.DomainKeys.friendImagePlaceholder.rawValue) as URL!)
                }
                
            } else {
                cell.fbImageView.sd_setImage(with: NSURL(string:DomainManager.DomainKeys.friendImagePlaceholder.rawValue) as URL!)
                
            }
            return cell
            
        }else if indexPath.section == 0 {
            //グループセクション
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            for subview in cell.contentView.subviews{
                subview.removeFromSuperview()
            }
            cell.addSubview(cell.nameLabel)
            cell.addSubview(cell.profileLabel)
            cell.addSubview(cell.jobInProgressLabel)
            cell.addSubview(cell.fbImageView)
            let thisGroup = groups[indexPath.row]
            cell.nameLabel.text = thisGroup.name
            let imageUrl = NSURL(string: DomainManager.DomainKeys.friendImagePlaceholder.rawValue)
            cell.fbImageView.sd_setImage(with: imageUrl as URL!)
            
            return cell
        } else if indexPath.section == 2 {
            //自分
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            for subview in cell.contentView.subviews{
                subview.removeFromSuperview()
            }
            cell.addSubview(cell.nameLabel)
            cell.addSubview(cell.profileLabel)
            cell.addSubview(cell.jobInProgressLabel)
            cell.addSubview(cell.fbImageView)
            if(ManipulateUserDefaults.getUserid() != nil){
                let userInfo = ManipulateUserDefaults.getUserInfo()
                let name = userInfo["name"] as! String
                print(name)
                //画像の表示
                cell.nameLabel.text = name
                if let photoURL = userInfo["photoURL"]{
                    let photoURLString = photoURL as! String
                    if(photoURLString.characters.count > 0 ){
                        let imageUrl = NSURL(string: photoURLString)
                        //cell.addSubview(cell.fbImageView)
                        cell.fbImageView.sd_setImage(with: imageUrl as URL!)
                    } else {
                        //cell.addSubview(cell.fbImageView)
                        cell.fbImageView.sd_setImage(with: NSURL(string:DomainManager.DomainKeys.friendImagePlaceholder.rawValue) as URL!)
                    }
                }
            }
            return cell
        } else {
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            for subview in cell.contentView.subviews{
                subview.removeFromSuperview()
            }
            cell.addSubview(cell.nameLabel)
            cell.addSubview(cell.profileLabel)
            cell.addSubview(cell.jobInProgressLabel)
            cell.addSubview(cell.fbImageView)
            return cell

        }
        
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //CreateJobViewControllerから来たときは選択時にもとの画面に戻る
        //TimelineViewControllerから（あいてるボタンを押下して)来た時は先へすすむ
        
        //一つ前の画面を取得
        let vcIndex = (self.navigationController?.viewControllers.count)! - 2

        
        if(transitionType == TransitionType.job){
            //選択されたidを渡して遷移
            if(indexPath.section == 1){
                let vc: CreateJobViewController = self.navigationController?.viewControllers[vcIndex] as! CreateJobViewController
                vc.id_friend = friends[indexPath.row].id_user
                vc.friend_name = friends[indexPath.row].name!
                self.navigationController?.popToViewController(vc, animated: true)
            } else if(indexPath.section == 0){
                let vc: CreateJobViewController = self.navigationController?.viewControllers[vcIndex] as! CreateJobViewController
                vc.id_group = groups[indexPath.row].id_group
                vc.group_name = groups[indexPath.row].name
                self.navigationController?.popToViewController(vc, animated: true)
            } else if(indexPath.section == 2){
                let vc: CreateJobViewController = self.navigationController?.viewControllers[vcIndex] as! CreateJobViewController
                if(ManipulateUserDefaults.getUserid() != nil){
                    let userInfo = ManipulateUserDefaults.getUserInfo()
                    let name = userInfo["name"] as! String
                    vc.id_friend = userInfo["id_user"] as! String
                    vc.friend_name = name
                    self.navigationController?.popToViewController(vc, animated: true)
                }

            }

           
        }else if(transitionType == TransitionType.keli){
            
            let vc = self.navigationController?.viewControllers[vcIndex]
            if(indexPath.section == 1){
                //友達の場合
                keliType = .friend
                id_friend_toPass = friends[indexPath.row].id_user
                friend_name_toPass = friends[indexPath.row].name!
            }else if(indexPath.section == 0){
                //グループの場合
                keliType = .group
                id_group_toPass = groups[indexPath.row].id_group
                group_name_toPass = groups[indexPath.row].name
            }else if(indexPath.section == 2){
                if(ManipulateUserDefaults.getUserid() != nil){
                    let userInfo = ManipulateUserDefaults.getUserInfo()
                    keliType = .friend
                    let name = userInfo["name"] as! String
                    id_friend_toPass = userInfo["id_user"] as! String
                    friend_name_toPass = name
                }
            }
            //セグエを実行して遷移する
            performSegue(withIdentifier: "ShowConfirmSegue", sender: tableView)

        }
    }
    
    //Segueが実行されるまえに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //TODO:ここでセクション取得できないので、遷移にセグエを使用しないことも検討したい
        if(segue.identifier == "ShowConfirmSegue"){
            let confirmVC: KeliConfirmViewController = (segue.destination as? KeliConfirmViewController)!
            //次の画面に渡す値をセットする
            confirmVC.thisKeliDict = keliToPass

            if(keliType == .friend) {
                confirmVC.targetFriendName = friend_name_toPass
                confirmVC.id_friend = id_friend_toPass
                confirmVC.keliType = .friend
            } else if (keliType == .group) {
                confirmVC.targetGroupName = group_name_toPass
                confirmVC.id_group = id_group_toPass
                confirmVC.keliType = .group
            }
            
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConstValue.globalCellHeight
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let title = ["グループ", "  友達", "  自分"]
        return title[section]
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = ConstValue.globalYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ConstValue.globalPink
        header.textLabel?.font = UIFont(name: "Hiragino Sans W6", size:13)
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
    
}
