//
//  FriendDetailViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/18.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift
import SDWebImage

class FriendDetailViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //友達リスト選択時に渡ってくるオブジェクト
    var friend = User()

    @IBOutlet weak var friendImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var profileLabel: UILabel!    
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var actionTable: UITableView!
    var doingJobList = [[String:Any]]()
    var doneJobList = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionTable.delegate = self
        actionTable.dataSource = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameLabel.text = friend.name
        profileLabel.text = friend.profile
        
        if let imageURLString: String = friend.photoURL {
            if(imageURLString.characters.count > 0){
                let imageURL = NSURL(string:imageURLString) as URL!
                friendImageView.sd_setImage(with: imageURL)
            }else {
                let placeHoldURL = DomainManager.DomainKeys.profileImagePlaceholder.rawValue
                let imageURL = NSURL(string:placeHoldURL) as URL!
                friendImageView.sd_setImage(with: imageURL)
            }
        }
        
        //APIからデータを取得する
        let resultHandler = {(resultArray: [[[String:Any]]])-> Void
        in
            self.doingJobList = resultArray[0]
            self.doneJobList = resultArray[1]

            //メインからでないと呼ばれない
            DispatchQueue.main.async {
                
                self.actionTable.reloadData()
            }
        }
        JobManager.getJobsByReceiverId(id_receiver: friend.id_user, resultHandler: resultHandler)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView:UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return doingJobList.count
        } else if(section == 1){
            return doneJobList.count
        }
        return 0
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell {
        //デフォルトのセルを使用中
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if !(cell  != nil){
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        }
        
        //print("doingjoblist",self.doingJobList)
        //print("donejoblist",self.doneJobList)
        if(indexPath.section == 0){
            let thisJob = doingJobList[indexPath.row]
            cell?.textLabel?.text = thisJob["title"] as! String?
            cell?.detailTextLabel?.text = thisJob["job_description"] as! String?
        } else if(indexPath.section == 1){
            let thisJob = doneJobList[indexPath.row]
            cell?.textLabel?.text = thisJob["title"] as! String?
            cell?.detailTextLabel?.text = thisJob["job_description"] as! String?
        }

        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let titleArray = ["  受けたジョブ", "  終了したジョブ"]
        return titleArray[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ConstValue.globalCellHeight * 2/3
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = ConstValue.globalYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ConstValue.globalPink
        header.textLabel?.font = UIFont(name: "Hiragino Sans W6", size:13)
    }
    
}
