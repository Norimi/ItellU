//
//  CreateJobViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/16.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit

class CreateJobViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var descriptionField: UITextField!
    @IBOutlet weak var targetLabel: UILabel!
    @IBOutlet weak var editTargetButton: UIButton!
    @IBOutlet weak var kickButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var commentTextView: UIBorderedTextView!

    //SelectFriendsViewControllerで選択された友達のidと名前が入る変数
    var id_friend: String = ""
    var friend_name = ""
    var id_group = 0
    var group_name = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ConstValueにフォント設定があるが
        //例外的に大きいボタンなのでここで設定
        kickButton.titleLabel?.font =  UIFont(name: "Hiragino Sans W6", size: 36)
        // Do any additional setup after loading the view.
        titleField.delegate = self
        descriptionField.delegate = self
        commentTextView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //SelectFriendViewControllerで選択された友達の名前が入る
        //TODO:値が残ったままにならないかテストする
        print("friend_name",friend_name)
        if(friend_name.characters.count > 0){
           targetLabel.text = friend_name + " へ"
        }
        if(group_name.characters.count > 0){
            targetLabel.text = group_name + " へ"
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
     ## JOBを作成してデータベースに格納する
     - ここでは、JOB作成と最初のKeliを同時に行う
     - 完了ハンドラ内で関連データをダウンロードする関数を呼ぶ
    */
    @IBAction func kickOff(_ sender: Any) {
        
        guard ManipulateUserDefaults.getUserid() != nil else {
            return
        }
        if(self.id_group == 0 && self.id_friend == ""){
            return
        }

        let urlKey = DomainManager.DomainKeys.createJob.rawValue
        let url = DomainManager.readDomainPlist(key:urlKey)
        //ハンドラ内からnewestKeliを取得するAPIをはじいて最新データを取得
        let completionHandler = {(_ data:Data?, _ resp:URLResponse?, _ err:Error?) -> Void
            in
            let response = resp as! HTTPURLResponse?
            let statusCode = response?.statusCode
            if(statusCode != 200){
                AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                return
            } else if(err != nil){
           
                AlertControllerManager.showAlertController("エラーです", "しばらくしてから\nもういちどお試しください", nil)
                return
            }
            DispatchQueue.main.async {
                KeliManager.downloadNewestKelis()
                JobManager.downloadNewestJobs()
                self.navigationController?.popToRootViewController(animated: true)
            }

        }
        KeliConnection.postMethodWithCompletionHandler(urlString:url, data:createPostData(), completionHandler: completionHandler)
        
    }
    
    @IBAction func cancelAndDismiss(_ sender: Any) {
    }

    func createPostData() -> Data{
        
        let uid = ManipulateUserDefaults.getUserid()
        let title = titleField.text
        let description = descriptionField.text
        let comment : String = commentTextView.text ?? ""
    
        let id_friend = self.id_friend
        let id_group = self.id_group
        let newData: [String:Any] = ["id_user": uid, "title":title, "job_description":description, "comment":comment, "id_friend":id_friend, "id_group":id_group]
        
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: newData, options: .prettyPrinted)
            //汎用通信メソッドの使用
            return jsonData
            
        } catch {
            //TODO:別に落とさないでもよい
            //このタイミングで送信できなかったら貯めておく
            fatalError("cant't make Json data")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if(UserManager.getAllFriends().count == 0 && GroupManager.getAllGroups().count == 0){
            return false
        } else {
            return true
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // TODO:友達とグループがなければセグエを使っての遷移をキャンセルする
        let selectFrVC: SelectFriendsTableViewController = segue.destination as! SelectFriendsTableViewController
        selectFrVC.transitionType = .job

    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleField.resignFirstResponder()
        descriptionField.resignFirstResponder()
        return true
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n"
        {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
   


