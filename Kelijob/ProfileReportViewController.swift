//
//  ProfileReportViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/01/23.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import RealmSwift

class ProfileReportViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var jobTitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var reportTable: UITableView!
    @IBOutlet weak var createReportBtn: UIBarButtonItem!
    @IBOutlet weak var doneBtn: UIButton!
    @IBOutlet weak var barBtnItem: UINavigationItem!
    
    var thisId_job = Int()
    var thisJob: Results<Job> {
        get { return JobManager.queryJobById(id_job: thisId_job) }
    }
    var reports: Results<Report> {
        get { return ReportManager.queryReportByIdJob(id_job:thisId_job)}
    }
   
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reportTable.delegate = self
        reportTable.dataSource = self
        
        setXibForCell()
        setJobLabel()
        if(thisJob[0].done == true){
            barBtnItem.rightBarButtonItem?.isEnabled = false
            
        }
    }
    
    func setJobLabel() {
        
        if let jobCreator = UserManager.queryUserById(id_user: thisJob[0].id_user) {
            nameLabel.text = jobCreator.name
        }
        jobTitleLabel.text = thisJob[0].title
        let created = thisJob[0].created
        let createdString = ConstValue.stringFromDate(date: created)
        dateLabel.text = createdString
        commentLabel.text = thisJob[0].job_description        
    }
    
    func setXibForCell() {
        let nib = UINib(nibName: "ReportCell", bundle:nil)
        self.reportTable.register(nib, forCellReuseIdentifier: "ReportCell")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: ReportCell = tableView.dequeueReusableCell(withIdentifier: "ReportCell", for: indexPath) as! ReportCell
        cell.noLabel.text = "Report No." + String(indexPath.row + 1)
        cell.reportLabel.text = reports[indexPath.row].comment
        let date = reports[indexPath.row].created
        let dateString = ConstValue.stringFromDate(date: date)
        cell.dateLabel.text = dateString
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //selectedIndex = indexPath.row
        //performSegue(withIdentifier: "ShowProfileReport", sender: self)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "作成したレポート"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = ConstValue.globalYellow
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = ConstValue.globalPink
        header.textLabel?.font = UIFont(name: "Hiragino Sans W6", size:13)
    }

    @IBAction func createReportBtnTouchUpInside(_ sender: Any) {
        performSegue(withIdentifier: "ShowCreateProfileReport", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let VC: CreateProfileReportViewController = segue.destination as! CreateProfileReportViewController
        let id_job = thisJob[0].id_job
        VC.thisJobDict = JobManager.getAJobDictByIdJob(id_job: id_job)
        //最後のレポートに紐づくid_keliを取得する
        if(reports.count > 0){
            VC.id_keli = reports[0].id_keli

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

}
