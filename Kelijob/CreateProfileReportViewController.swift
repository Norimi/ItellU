//
//  CreateProfileReportViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/23.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class CreateProfileReportViewController: UIViewController, UITextViewDelegate {
    @IBOutlet weak var reportTextView: UIBorderedTextView!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var doneBtn: UIButton!
    
    var id_keli = Int()
    //var thisJob = Job()
    var thisJobDict = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.reportTextView.delegate = self
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        doneBtn.tag = 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        doneBtn.tag = 0
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendBtnTouchUpInside(_ sender: Any) {
        //レポート作成と同時にKeli作成するAPIにPOSTする
        if(reportTextView.text.characters.count == 0){
            return
        }
        //TODO:画像を入れる
        let uid = ManipulateUserDefaults.getUserid()
        let reportString = reportTextView.text
        
        var done = false
        if(doneBtn.tag == 1){
            done = true
        } else {
            done = false
        }
        let newData: [String:Any?] = ["id_user":uid!, "id_job":thisJobDict["id_job"], "id_keli":id_keli, "report":reportString, "image":"", "done":done]
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newData, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.createReport.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ data:Data?, _ resp: URLResponse?, _ error:Error?) -> Void
                in
                let response = resp as! HTTPURLResponse?
                let statusCode = response?.statusCode
                if(statusCode != 200){
                    AlertControllerManager.showAlertController("エラーです", "通信状況をお確かめの上\nもう一度お試しください", nil)
                    return
                }
                if(error != nil){
                    
                    AlertControllerManager.showAlertController("エラーです", "しばらくしてから\nもういちどお試しください", nil)
                    return
                }

                DispatchQueue.main.async {
                    KeliManager.downloadNewestKelis()
                    ReportManager.downloadNewestReports()
                    JobManager.downloadNewestJobs()
                    self.navigationController?.popToRootViewController(animated: true)

                }
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonData, completionHandler: completionHandler)
            
            
        } catch {
            print("JSON error in sendBtnTOuchUpInside")
        }
    }
    

    @IBAction func doneBtnTouchUpInside(_ sender: UIButton) {
        
        if(sender.tag == 0) {
            //ボタンのtagで判定してjobにdoneを入れる
            //doneにひもづくkeliを作成する
            //report作成不可にする:doneが入っているときはdoneボタンとレポート作成ボタンをhiddenにする
            sender.tag = 1
            doneBtn.isSelected = true;
            doneBtn.setTitleColor(UIColor(red:0.95, green:0.51, blue:0.51, alpha:1.0), for: .selected)
            doneBtn.setTitle("このジョブを完了する : ON", for: .selected)
            doneBtn.backgroundColor = UIColor.clear
            
        } else {
            
            sender.tag = 0
            doneBtn.isSelected = false;
            doneBtn.setTitleColor(UIColor.lightGray, for: .normal)
            doneBtn.setTitle("このジョブを完了する : OFF", for: .normal)
            doneBtn.backgroundColor = UIColor.clear
        }

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
