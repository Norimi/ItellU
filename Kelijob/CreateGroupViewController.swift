//
//  CreateGroupViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/20.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class CreateGroupViewController: UITableViewController {

    var friends: Results<User> {
        get { return UserManager.getAllFriends() }
    }
    var id_group = 0
    
    var searchController = UISearchController()
    let searchFrController = FriendSearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibForCell()
        setSearchController()
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        //前のviewControllerからid_groupを取得する
        /* 以下前画面から渡すことにした
        let beforeVCIndex = (self.navigationController?.viewControllers.count)! - 2
        let vc: GroupDefinitionViewController = self.navigationController?.viewControllers[beforeVCIndex] as! GroupDefinitionViewController
        self.id_group = vc.id_group
        print("id_group in create group", self.id_group)
        */
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(true)

    }
    
    func setXibForCell() {
        
        let nib = UINib(nibName: "AddFrGroupCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "AddFrGroupCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backToTop(_ sender: Any) {
        self.navigationController?.popToRootViewController(animated:true)
    }
    

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return friends.count
    }

  
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        let cell: AddFrGroupCell = tableView.dequeueReusableCell(withIdentifier: "AddFrGroupCell", for:indexPath) as! AddFrGroupCell
        if(friends.count == 0){
            return cell
        }
        cell.addButton.tag = indexPath.row
        cell.addButton.addTarget(self, action: #selector(addButtonTouchUpInside(sender:)), for: .touchUpInside)
        let thisFriend = friends[indexPath.row]
        cell.nameLabel.text = thisFriend.name ?? ""
        if let profile: String = thisFriend.profile {
            cell.descriptionLabel.text = profile
        }
        // Configure the cell...

        return cell
    }
    
    func addButtonTouchUpInside(sender:UIButton) {
        //グループ登録処理
        

        //友達のidを自身(id_user)として送信する
        let id_user = friends[sender.tag].id_user
        
        sender.setTitleColor(UIColor.lightGray, for: .normal)
        sender.titleLabel?.text = "追加済"
        sender.isEnabled = false
        
        
        let dataDict:[String:Any] = ["id_user":id_user, "id_group":id_group, "id_friend":"0"]
        do {
            let jsonDict = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.createRelation.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)

            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
                in
                if(data == nil){
                    AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                    return
                }
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
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonDict, completionHandler:completionHandler)
            
        } catch {
            print("JSON error in addButtonTouchUpInside")
        }
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //表示されるときの最終的な値はここで決定される
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

extension CreateGroupViewController: UISearchResultsUpdating {
    
    func setSearchController(){
        
        searchFrController.searchType = .group
        searchFrController.id_group = self.id_group
        searchController = UISearchController.init(searchResultsController: searchFrController)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        self.tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        searchController.searchBar.placeholder = "友達を検索して追加"
//        searchController.searchBar.backgroundColor = ConstValue.globalGreen
        
    }
    func updateSearchResults(for searchController: UISearchController){
        
        if (searchController.searchBar.text == ""){
            return
        }
        
        //通信してリモートDBを検索し結果を返す
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
        if let text = searchController.searchBar.text {
            let dict:[String:String] = ["name":text, "id_user":uid];
            
            do {
                
                var tmpFriendList = [Any]()
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let urlKey = DomainManager.DomainKeys.searchFriend.rawValue
                let url = DomainManager.readDomainPlist(key: urlKey)
                let completionHandler = {[unowned self](_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void in
                    
                    do {
                        if(data == nil){
                            return
                        }
                        let userData: Any = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        let newData = userData as! Array<Any>
                        
                        for i in 0..<newData.count {
                            
                            var thisUser = [String:Any]()
                            let newDict:[String:Any] = newData[i] as! [String:Any]
                            
                            if let id_user = newDict["id_user"] {
                                thisUser["id_user"] = id_user
                            }
                            
                            if let name = newDict["name"]{
                                thisUser["name"] = name
                            }
                            
                            if let email = newDict["email"]{
                                thisUser["email"] = email
                            }
                            
                            if let profile = newDict["profile"] {
                                thisUser["profile"] = profile
                            }
                            
                            if let photoURL = newDict["photoURL"] {
                                thisUser["photoURL"] = photoURL
                            }
                            
                            if let created = newDict["created"] as! String? {
                                if let date = ConstValue.convertDateFromString(created) {
                                    thisUser["created"] = date
                                }
                            }
                            
                            if let status = newDict["status"] as! String? {
                                thisUser["status"] = status
                            }
                            
                            tmpFriendList.append(thisUser)
                        }
                        
                    } catch {
                        
                        print("error in JSON Serializing / updateSearchResults")
                    }
                    //通信終了のたびreloaddataする
                    print("end of handler")
                    self.searchFrController.friendList.removeAll()
                    self.searchFrController.friendList = tmpFriendList
                    self.searchFrController.tableView.reloadData()
                }
                
                KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
                
                
            } catch {
                
                print("error in JSON Serializing / updateSearchResults")
                
            }
            
        }        
    }
}
