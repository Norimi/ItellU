//
//  CreateReportViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2016/12/21.
//  Copyright © 2016年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class CreateReportViewController: UIViewController, UITextViewDelegate {

    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var reportTextView: UIBorderedTextView!
    @IBOutlet weak var reportImageView: UIImageView!
    @IBOutlet weak var sendReportBtn: UIButton!
    
    var keli = Keli()
    var jobs : Results<Job> {
        get { return JobManager.queryJobById(id_job:keli.id_job)}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportTextView.delegate = self

        // Do any additional setup after loading the view.
        if(jobs.count > 0){
            titleLabel.text = jobs[0].title! + "を受けます!"
        }
        
        let comments = CommentManager.queryCommentByIdKeli(id_keli:keli.id_keli)
        if(comments.count > 0){
            commentLabel.text = comments[0].comment
        }
    }
    
    
    @IBAction func sendReportTouchUpInside(_ sender: Any) {
        
        let data = createReportJSONData() ?? Data()
        let urlKey = DomainManager.DomainKeys.createReport.rawValue
        let url = DomainManager.readDomainPlist(key: urlKey)
        let completionHandler = {(data:Data?, resp:URLResponse?, err:Error?) -> Void in
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
          
            //完了ハンドラ終了後やりたいことを記述
            //メインスレッドで実行しないとできません
            DispatchQueue.main.async {
                KeliManager.downloadNewestKelis()
                JobManager.downloadNewestJobs()
                ReportManager.downloadNewestReports()
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        KeliConnection.postMethodWithCompletionHandler(urlString: url, data:data, completionHandler: completionHandler)

    }

    
    func createReportJSONData() -> Data? {
        //このデータもkeliとして記録される/Keliとして表示はされず、紐づくレポートが表示される
        let imageURL = String()
        let reportString: String? = reportTextView.text ?? ""
        guard let uid = ManipulateUserDefaults.getUserid() else {
            return Data()
        }
        
        let newData: [String : Any?] = ["id_user": uid,"id_job": jobs[0].id_job, "id_keli": keli.id_keli, "report": reportString, "image": imageURL, "done":false]
        do{
            let jsonData = try JSONSerialization.data(withJSONObject: newData, options: .prettyPrinted)
            return jsonData
            
        }catch {
            
            fatalError("error in creating JSON data")
        }
        
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
