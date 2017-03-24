//
//  FriendSearchViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/12.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import SDWebImage

class FriendSearchViewController: UITableViewController{
    
    enum SearchType {
        case applying
        case group
    }
    
    var searchType = SearchType.applying
    var id_group = Int()
    
    var friendList = Array<Any>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibForCell()
    }
    

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
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friendList.count
    }
    
    /*
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    */
  
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {


        let cell: FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
        
        
        for subview in cell.contentView.subviews{
            subview.removeFromSuperview()
        }
    
        let thisFriend:[String:Any] = friendList[indexPath.row] as! [String:Any]

        if let friendName = thisFriend["name"]{
            cell.nameLabel.text = (friendName as? String)!
            //セル再描画の際にremoveしているのでaddする
            cell.addSubview(cell.nameLabel)
        }
        
        if let friendProfile = thisFriend["profile"] {
            cell.profileLabel.text = friendProfile as? String
            cell.addSubview(cell.profileLabel)
        }
        
        cell.addSubview(cell.fbImageView)
        if let photoURLString = thisFriend["photoURL"] as! String? {
            if(photoURLString.characters.count > 0){
                let photoURL = NSURL(string: photoURLString) as URL!
                cell.fbImageView.sd_setImage(with: photoURL)
            } else {
               
            }
        } else {
            let photoDomain = DomainManager.DomainKeys.friendImagePlaceholder
            let photoURL = NSURL(string: photoDomain.rawValue) as URL!
            cell.fbImageView.sd_setImage(with: photoURL)
        }
        
        //このボタンはトグル
        //TODO:プロフィールに申請中の友達を表示する
        cell.applyBtn.isUserInteractionEnabled = true
        cell.applyBtn.backgroundColor = UIColor.clear
        cell.applyBtn.addTarget(self, action: #selector(applyBtnTouchUpInside(sender:)), for: .touchUpInside)
        cell.applyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 30)
        cell.applyBtn.tag = indexPath.row
        cell.addSubview(cell.applyBtn)
        
        if (thisFriend["status"] as? String == "no_relation"){
            cell.applyBtn.setTitle("+", for: .normal)
            cell.applyBtn.setTitleColor(UIColor(red:0.95, green:0.51, blue:0.51, alpha:1.0), for: .normal)
            cell.applyBtn.isHidden = false
            
        } else if(thisFriend["status"] as? String == "applying"){
            
            cell.applyBtn.setTitle("申請中", for: .normal)
            cell.applyBtn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
            cell.applyBtn.setTitleColor(UIColor.lightGray, for: .normal)
            cell.applyBtn.isHidden = false
            
        } else {
           
            //関係がある場合とくに何も表示しない（APIを用意していないので)
            cell.applyBtn.setTitle("", for: .normal)
            cell.applyBtn.setTitleColor(UIColor.lightGray, for: .normal)
            cell.applyBtn.isHidden = true
            cell.applyBtn.isUserInteractionEnabled = false
        }
        //TODO:すでに友達の場合など
        
        return cell
     }
    
    func applyBtnTouchUpInside(sender: UIButton){
        
        //処理をはやく見せるためここで表示を変更する
        sender.backgroundColor = UIColor.clear
        sender.isUserInteractionEnabled = false
        
        var postDict = [String:Any]()
    
        switch searchType {
        case .applying:
            sender.setTitle("申請中", for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            sender.setTitleColor(UIColor.lightGray, for: .normal)
            let id_user = ManipulateUserDefaults.getUserid()
            let thisFriend:[String:Any?] = friendList[sender.tag] as! [String : Any?]
            let id_friend = thisFriend["id_user"] 
            postDict = ["id_user":id_user ?? "", "id_friend":id_friend, "id_group":0];

        case .group:
            sender.setTitle("追加済", for: .normal)
            sender.titleLabel?.font = UIFont.systemFont(ofSize: 18)
            sender.setTitleColor(UIColor.lightGray, for: .normal)
            let thisFriend:[String:Any?] = friendList[sender.tag] as! [String : Any?]
            let id_friend = thisFriend["id_user"]
            let id_user = id_friend
            postDict = ["id_user":id_user, "id_friend":"0", "id_group":id_group]
            
        }

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.createRelation.rawValue
            let url = DomainManager.readDomainPlist(key:urlKey)
 
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void in
                let response = resp as! HTTPURLResponse?
                let statusCode = response?.statusCode
                if(statusCode != 200){
                    AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                    return
                }
                if(err != nil){
                    
                    AlertControllerManager.showAlertController("エラーです", "しばらくしてから\nもういちどお試しください", nil)
                    return
                }

            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler:completionHandler)
            
            
        } catch {
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConstValue.globalCellHeight
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

