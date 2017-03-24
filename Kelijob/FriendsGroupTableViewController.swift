//
//  FriendsGroupTableViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/17.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//


import UIKit
import RealmSwift
import SDWebImage

class FriendsGroupTableViewController: UITableViewController {

    var friends : Results<User> {
        get { return UserManager.getAllFriends() }
    }
    var groups : Results<Group>{
        get { return GroupManager.getAllGroups() }
    }
    @IBOutlet weak var searchFriendBtn: UIBarButtonItem!
    
    var selectedFriend = User()
    var selectedGroup_id = Int()
    var searchController = UISearchController()
    var applyingFriendArray = Array<ApplyingUser>()
    //グループの友達表示時に一時的にデータを格納する
    var friendsArray = [[String:Any]]()

    
    //友達検索結果表示画面
    let searchFrController = FriendSearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setXibForCell()
        setSearchController()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //友達申請を取得し、取得後にreloaddataする
        super.viewWillAppear(true)
        DispatchQueue.global(qos: .default).async {
            UserManager.getFriendApplication(reloadDataHandler: {(applyingFriendArray)-> Void in
                self.applyingFriendArray = applyingFriendArray
            })
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    func setXibForCell() {
        
        let nib = UINib(nibName: "FriendsGroupCell", bundle: nil)
        self.tableView.register(nib, forCellReuseIdentifier: "FriendsGroupCell")
        let nib2 = UINib(nibName: "ApplyFriendsCell", bundle: nil)
        self.tableView.register(nib2, forCellReuseIdentifier: "ApplyFriendsCell")
        let nib3 = UINib(nibName:"AddCell", bundle:nil)
        self.tableView.register(nib3, forCellReuseIdentifier: "AddCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        //申請中とグループと友達個人に分けて2とする
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return applyingFriendArray.count
        } else if section == 2 {
            //グループ作成ボタンを使用するため + 1 を設定する
            return groups.count + 1
        } else if section == 1 {
            
            return friends.count
        } else if section == 3{
            return 1
        }else {
            return 0
        }
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
     
        var applyTitle = ""
        if(applyingFriendArray.count > 0) {
            applyTitle = "  友達申請"
        }
        let title = [applyTitle, "  友達", "  グループ", "  自分"]
        return title[section]

    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = ConstValue.globalYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ConstValue.globalPink
        header.textLabel?.font = UIFont(name: "Hiragino Sans W6", size:13)

    }

   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if indexPath.section == 0{
            //申請中
            
            let appCell: ApplyFriendsCell = tableView.dequeueReusableCell(withIdentifier: "ApplyFriendsCell", for: indexPath) as! ApplyFriendsCell
            
            for subview in appCell.contentView.subviews{
                subview.removeFromSuperview()
            }
            
            let thisFriend:ApplyingUser = applyingFriendArray[indexPath.row]
            appCell.nameLabel.text = thisFriend.name
            appCell.profileLabel.text = thisFriend.profile
            
            appCell.addSubview(appCell.nameLabel)
            appCell.addSubview(appCell.profileLabel)
            
            appCell.acceptBtn.titleLabel?.font =  UIFont(name: "Hiragino Sans W6", size: 15)
            appCell.deleteBtn.titleLabel?.font =  UIFont(name: "Hiragino Sans W6", size: 15)
      
            appCell.acceptBtn.addTarget(self, action: #selector(acceptBtnTouchUpInside(sender:)), for: .touchUpInside)
            appCell.acceptBtn.tag = indexPath.row
            appCell.addSubview(appCell.acceptBtn)
            //xibで設定しているが、押下後disabledになるのでcellが読まれるたびに設定する
            appCell.acceptBtn.backgroundColor = UIColor.clear
            appCell.acceptBtn.setTitleColor(ConstValue.globalPink, for: .normal)
            appCell.acceptBtn.setTitle("友達になる", for: .normal)
            
            appCell.deleteBtn.setTitleColor(UIColor.lightGray, for: .normal)
            appCell.deleteBtn.addTarget(self, action: #selector(deleteBtnTouchUpInside(sender:)), for: .touchUpInside)
            appCell.deleteBtn.tag = indexPath.row
            appCell.addSubview(appCell.deleteBtn)
            
            if let photoURLString = thisFriend.photoURL {
                if(photoURLString.characters.count > 0){
                    let photoURL = NSURL(string: photoURLString) as URL!
                    appCell.friendImageView.sd_setImage(with: photoURL)
                } else {
                    let photoURLString = DomainManager.DomainKeys.friendImagePlaceholder.rawValue
                    let photoURL = NSURL(string: photoURLString) as URL!
                    appCell.friendImageView.sd_setImage(with: photoURL)
                }
            }
            appCell.addSubview(appCell.friendImageView)
            
            return appCell
       
        }else if indexPath.section == 2 {
            //グループの表示

            //TODO:セルの要素がnilになるのでとりあえずコメントアウト
            //            for subview in cell.contentView.subviews{
            //                subview.removeFromSuperview()
            //            }

            if(indexPath.row == groups.count){
                
                let cell: AddCell = tableView.dequeueReusableCell(withIdentifier: "AddCell", for: indexPath) as! AddCell
                return cell
                
            } else {
                
                let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
                let thisGroup = groups[indexPath.row]
                cell.nameLabel.text = thisGroup.name
                cell.profileLabel.text = thisGroup.group_description
                let imageUrl = NSURL(string: DomainManager.DomainKeys.friendImagePlaceholder.rawValue)
                cell.fbImageView.sd_setImage(with: imageUrl as URL!)
                cell.jobInProgressLabel.text = ""
                cell.addSubview(cell.nameLabel)
                cell.addSubview(cell.profileLabel)
                return cell
            }
            
            
        }else if indexPath.section == 1 {
            
            //友達の表示
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            for subview in cell.contentView.subviews{
                subview.removeFromSuperview()
            }
            cell.addSubview(cell.nameLabel)
            cell.addSubview(cell.profileLabel)
            cell.addSubview(cell.jobInProgressLabel)
            cell.addSubview(cell.fbImageView)
            
            //trueに設定する箇所に対応してデフォルトfalseを設定
            cell.isHidden = false
            if(friends.count == 0){
                return cell
            }
            
            let thisFriend = friends[indexPath.row]
            if(thisFriend.name != nil){
               cell.nameLabel.text = thisFriend.name ?? ""
            }
            
            if let profile: String = thisFriend.profile {
                cell.profileLabel.text = profile
            } else {
                cell.profileLabel.text = ""
            }
            
            //画像の表示
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

            let ukeJobs : Results<Job> = JobManager.queryJobByReceiver(receiver_id_user:thisFriend.id_user)
            if(ukeJobs.count == 0){
                cell.jobInProgressLabel.text = ""
                return cell
            }

            //reportを取得する
            //modifiedでソートされて返される
            let thisReport = ReportManager.queryReportByIdJob(id_job:ukeJobs[0].id_job)
            if(thisReport.count == 0){
                return cell
            }
            let comment : String = thisReport[0].comment ?? ""
            cell.jobInProgressLabel.text = ukeJobs[0].title! + " : " + comment

            return cell
            
        } else if(indexPath.section == 3){
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
                cell.nameLabel.text = name
                let ukeJobs : Results<Job> = JobManager.queryJobByReceiver(receiver_id_user:userInfo["id_user"] as! String)
                if(ukeJobs.count == 0){
                    cell.jobInProgressLabel.text = ""
                    return cell
                }
                let thisReport = ReportManager.queryReportByIdJob(id_job:ukeJobs[0].id_job)
                if(thisReport.count == 0){
                    return cell
                }
                let comment : String = thisReport[0].comment ?? ""
                cell.jobInProgressLabel.text = ukeJobs[0].title! + " : " + comment
                //画像の表示
                if let photoURL = userInfo["photoURL"]{
                    let photoURLString = photoURL as! String
                    if(photoURLString.characters.count > 0 ){
                        let imageUrl = NSURL(string: photoURLString)
                        cell.addSubview(cell.fbImageView)
                        cell.fbImageView.sd_setImage(with: imageUrl as URL!)
                    } else {
                        cell.addSubview(cell.fbImageView)
                        cell.fbImageView.sd_setImage(with: NSURL(string:DomainManager.DomainKeys.friendImagePlaceholder.rawValue) as URL!)
                    }
                    
                } else {
                    cell.fbImageView.sd_setImage(with: NSURL(string:DomainManager.DomainKeys.friendImagePlaceholder.rawValue) as URL!)
                    
                }
            }
            return cell
      } else {
            
            
            let cell : FriendsGroupCell = tableView.dequeueReusableCell(withIdentifier: "FriendsGroupCell", for: indexPath) as! FriendsGroupCell
            //表示崩れに対応するためPlaceholderを表示
            let imageUrl = NSURL(string: DomainManager.DomainKeys.friendImagePlaceholder.rawValue)
            cell.fbImageView.sd_setImage(with: imageUrl as URL!)
            return cell
            
        }
    }
    
  
    func acceptBtnTouchUpInside(sender:UIButton) {
        
        sender.backgroundColor = UIColor.gray
        sender.setTitle("友達", for: .normal)
        
        let thisFriend = applyingFriendArray[sender.tag]
        applyingFriendArray.remove(at: sender.tag)
        tableView.reloadData()
        
        let uid = ManipulateUserDefaults.getUserid()
        print("sendertag", sender.tag)
        let id_friend = thisFriend.id_user
        let id_relation = thisFriend.id_relation
        let postDict = ["id_relation":id_relation, "id_friend":id_friend, "id_user":uid!] as [String : Any]

        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.acceptApplication.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_data: Data?, _ resp: URLResponse?, _ err: Error?) -> Void
                in
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
                //UI更新に対応のためメインスレッドで行う
                DispatchQueue.main.async {
                    UserManager.downloadNewestFriends()
                }
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
            
        } catch {
            
        }
        
    }
    
    //TODO:未試行
    func deleteBtnTouchUpInside(sender:UIButton) {
        
        if(ManipulateUserDefaults.getUserid() == nil){
            return
        }
        
        let thisFriend = applyingFriendArray[sender.tag]
        applyingFriendArray.remove(at: sender.tag)
        tableView.reloadData()
        
        let id_relation = thisFriend.id_relation
        let postDict = ["id_relation":id_relation]
        do {
            let jsonDict = try JSONSerialization.data(withJSONObject: postDict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.deleteRelation.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
            in
                //通信エラーのみ補足
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
            
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonDict, completionHandler: completionHandler)
            
        } catch {
            
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        //詳細画面を表示
        if(indexPath.section == 2){
            if(indexPath.row == groups.count){
                //グループの+ボタン押下
                //グループ定義画面へ遷移
                performSegue(withIdentifier: "CreateGroup", sender: self)
                tableView.deselectRow(at: indexPath, animated: true)
            } else {
                
                //グループのメンバーをリモートから取得して表示する画面へ遷移
                let resultHandler = {(_ friendsArray:[[String:Any]]) -> Void
                    in
                    self.friendsArray = friendsArray
                    if(friendsArray.count > 0){
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "ShowFriendsInGroup", sender: nil)
                        }
                    }
                }
                selectedGroup_id = groups[indexPath.row].id_group
                UserManager.getFriendsFromGroup(id_group:groups[indexPath.row].id_group, resultHandler:resultHandler)
               
                
            }
            
        } else if(indexPath.section == 1){
            selectedFriend = friends[indexPath.row]
            performSegue(withIdentifier: "ShowUsersSegue", sender: self)
            tableView.deselectRow(at: indexPath, animated: true)

        }
        
    }
    
    //Segueが実行されるまえに呼ばれる
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if(segue.identifier ==  "ShowUsersSegue"){
            let detailVC : FriendDetailViewController = (segue.destination as? FriendDetailViewController)!
            detailVC.friend = selectedFriend
        }
        
        if(segue.identifier == "ShowFriendsInGroup"){
            let frGrVC: FriendsInGroupTableViewController = (segue.destination as? FriendsInGroupTableViewController)!
            frGrVC.transitionType = .profile
            frGrVC.friendsArray = self.friendsArray
            frGrVC.id_group = self.selectedGroup_id
        }
    }
    
    @IBAction func searchFriendTouchupInside(_ sender: Any) {
        let frSearchVC = FriendSearchViewController()
        present(frSearchVC, animated: true, completion: nil)
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


extension FriendsGroupTableViewController: UISearchResultsUpdating {
    
    func setSearchController() {
        searchFrController.searchType = .applying
        searchController = UISearchController.init(searchResultsController: searchFrController)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        self.tableView.tableHeaderView = searchController.searchBar
        self.definesPresentationContext = true
        searchController.searchBar.placeholder = "友達を検索して申請"
        
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if (searchController.searchBar.text == ""){
            return
        }
        
        //通信してリモートDBを検索し結果を返す
        let uid = ManipulateUserDefaults.getUserid()
        if let text = searchController.searchBar.text {
            let dict:[String:String] = ["name":text, "id_user":uid!];
            
            do {
                
                var tmpFriendList = [Any]()
                let jsonData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
                let urlKey = DomainManager.DomainKeys.searchFriend.rawValue
                let url = DomainManager.readDomainPlist(key: urlKey)
                let completionHandler = {[unowned self](_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void in
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


