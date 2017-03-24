//
//  KeliConfirmViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/10.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class KeliConfirmViewController: UIViewController, UITextViewDelegate {
  
    //friendのとき使用
    //var thisKeli = Keli()
    
    //前の画面(selectFriendViewController)から渡ってくるkeli
    //groupのとき使用
    var thisKeliDict = [String:Any]()
    
    var id_friend: String = ""
    var id_group: Int = 0
    var targetFriendName: String = ""
    var targetGroupName: String = ""
    //var id_job: Int = 0

    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var commentTextView: UIBorderedTextView!
    @IBOutlet weak var jobLabel: UILabel!
    @IBOutlet weak var friendGroupLabel: UILabel!
    
    //target グループ or 友達
    enum KeliType {
        case group
        case friend
    }
    var keliType = KeliType.friend
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTextView.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //Jobを検索してラベルに表示
        if let id_keli: Int = thisKeliDict["id_keli"] as! Int? {
            let relatedJob = KeliManager.queryJobByIdKeli(id_keli: id_keli)
            if((relatedJob?.count)! > 0){
                //友達に蹴られているが。jobは作成時にgroupに紐づいている場合がある
                //jobからid_groupを取得して挿入する
                //groupのidを取得、上書きされない限り保持
                let id_group_fromDict = thisKeliDict["keli_to_groupid"] as! Int
                if(id_group_fromDict == 0){
                    self.id_group = relatedJob![0].id_group
                }
                let relatedJobTitle = relatedJob?[0].title
                jobLabel.text = relatedJobTitle! + "を"
            }
        }

        
        if(keliType == .friend){
            friendGroupLabel.text = targetFriendName + "に"
            id_group = 0
        } else if(keliType == .group) {
            friendGroupLabel.text = targetGroupName + "に"
            id_friend = ""
        }
        
    }

    
    @IBAction func okBtnTouchUpInside(_ sender: Any) {
        
        let comment = commentTextView.text ?? ""
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return
        }
       
        //直前のkeliデータを取得
        let id_job = thisKeliDict["id_job"] as! Int
        let id_keli = thisKeliDict["id_keli"] as! Int
        
        //次画面でグループが選択された場合はid_groupに値が入っている
        let dict = ["id_job":id_job, "keli_from_userid":uid, "keli_to_userid":id_friend, "keli_to_groupid":id_group, "id_keli_before":id_keli, "comment":comment] as [String : Any]
        do {
            let keliData = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.createKeli
            let url = DomainManager.readDomainPlist(key:urlKey.rawValue)
            let completionHandler = {(_ data:Data?, _ resp: URLResponse?, _ err:Error?) -> Void
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
                //完了ハンドラで最新データを取得する
                //Keliが増えるだけなのでJobは追加しない
                DispatchQueue.main.async {
                    KeliManager.downloadNewestKelis()
                    KeliManager.downloadNewestKelis()
                    JobManager.downloadNewestJobs()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            
            }
            KeliConnection.postMethodWithCompletionHandler(urlString:url, data:keliData, completionHandler:completionHandler)
            
        } catch {
            print("error in JSON selializing")
        }
    }

    @IBAction func cancelBtnTouchUpInside(_ sender: Any) {
        
        self.navigationController?.popToRootViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }

}
