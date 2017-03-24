//
//  EULAViewController.swift
//  
//
//  Created by netNORIMINGCONCEPTION on 2017/02/09.
//
//

import UIKit

class EULAViewController: UIViewController {
    @IBOutlet weak var okButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func okButtonTouchUpInside(_ sender: Any) {
        ManipulateUserDefaults.setOKEula()
        dismiss(animated: true, completion: {() -> Void
            in
        })
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
