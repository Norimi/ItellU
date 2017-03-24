//
//  FriendsInGroupTableViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/24.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

/**
 ## FriendsGroupViewControllerでグループ選択後、友達を表示するViewを表示します。
 - セル選択時に発動されたgetFriendsFromGroup()の結果をfriendsArrayに保持します。
 */

class FriendsInGroupTableViewController: UITableViewController {
    
    //KeliのときのGroup選択時->選択して戻る
    //Job作成時のGroup選択時->選択して次の画面へidをわたす
    //プロフィールからのグループ選択時
    enum TransitionType {
        case keli
        case profile
    }
    var transitionType = TransitionType.profile
    var friendsArray = [[String:Any]]()
    //keliのときkeliConfirmに渡す
    var id_friend = String()
    var friend_name = String()
    //var passedKeli = Keli()
    var passedKeliDict = [String:Any]()
    var id_group  = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibForCell()
    }
    
    func setXibForCell() {
        let nib = UINib(nibName: "FriendsGroupCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FriendsGroupCell")
        let nib2 = UINib(nibName: "AddCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "AddCell")
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
        var countNum = Int()
        if(transitionType == .profile){
            countNum = friendsArray.count + 1
        } else {
            countNum = friendsArray.count
        }
        return countNum
    }

 
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell: FriendsGroupCell = self.tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell") as! FriendsGroupCell
        
        if(transitionType == .profile){
            
            if(indexPath.row == friendsArray.count){
                let cell: AddCell = self.tableView.dequeueReusableCell(withIdentifier: "AddCell") as! AddCell
                return cell
            }
        }
        
        
        let thisFriendDict = friendsArray[indexPath.row]
        cell.nameLabel.text = thisFriendDict["name"] as! String?
        cell.profileLabel.text = thisFriendDict["profile"] as! String?
        cell.jobInProgressLabel.text = ""
        //オプショナルをアンラップしさらに文字列が0以上あるか確認が必要
        if let photoURLString = thisFriendDict["photoURL"] as! String? {
            if(photoURLString.characters.count > 0){
                let photoURL = NSURL(string: photoURLString) as URL!
                cell.fbImageView.sd_setImage(with: photoURL)
            } else {
                let photoDomain = DomainManager.DomainKeys.friendImagePlaceholder
                let photoURL = NSURL(string: photoDomain.rawValue)
                cell.fbImageView.sd_setImage(with: photoURL as URL!)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        //追加ボタン押下時
        if(indexPath.row == friendsArray.count){
            performSegue(withIdentifier: "ShowAddFriendsGroup", sender: tableView)
            return
        }
        
        if(transitionType == .keli){
            id_friend = friendsArray[indexPath.row]["id_user"] as! String
            self.friend_name = friendsArray[indexPath.row]["name"] as! String
            performSegue(withIdentifier: "ShowKeliConfirm", sender: tableView)
        }else if(transitionType == .profile){
            
        }
 
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "ShowKeliConfirm") {
            let VC:KeliConfirmViewController = segue.destination as! KeliConfirmViewController
            VC.keliType = .friend
            VC.thisKeliDict = self.passedKeliDict
            //ユーザー情報は名前だけで検索するまでもないのでidと名前を渡す
            VC.id_friend = self.id_friend
            VC.targetFriendName = self.friend_name
        } else if(segue.identifier == "ShowAddFriendsGroup"){
            let VC: CreateGroupViewController = segue.destination as! CreateGroupViewController
            VC.id_group = self.id_group
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let title = "  グループのメンバー"
        return title
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
