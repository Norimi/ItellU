//
//  GroupDefinitionViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/19.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class GroupDefinitionViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    @IBOutlet weak var okButton: UIButton!
    @IBOutlet weak var groupNameField: UITextField!
    @IBOutlet weak var descriptionField: UIBorderedTextView!
    
    //postして戻ってきたidを入れておく変数
    var id_group: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionField.delegate = self
        groupNameField.delegate = self

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //表示するたびリセットする
        id_group = 0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC: CreateGroupViewController = segue.destination as! CreateGroupViewController
        VC.id_group = self.id_group
    }
    
    @IBAction func okButtonTouchUpInside(_ sender: Any) {
        

        guard let name = groupNameField.text else {
            return
        }
        
        //名前の入力がない場合は抜ける
        if(groupNameField.text?.characters.count == 0){
            return
        }
        
        let description = descriptionField.text ?? ""
        let uid = ManipulateUserDefaults.getUserid()
        let dataDict = ["name":name, "description":description, "id_user":uid]
        
        do {
            
            let jsonData = try JSONSerialization.data(withJSONObject: dataDict, options: .prettyPrinted)
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
                let id_group = try! JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                self.id_group = (id_group as AnyObject).intValue
                DispatchQueue.main.async {
                    GroupManager.downloadNewestGroups()
                    self.performSegue(withIdentifier: "ShowCreateGroup", sender: nil) 
                }

            }
            let urlKey = DomainManager.DomainKeys.createGroup.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
            
        } catch {
            
        }
        
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
