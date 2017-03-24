//
//  EditProfileViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/02/20.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit

class EditProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var openAlbumBtn: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func openBtnTouchUpInside(_ sender: Any) {
        let ipc: UIImagePickerController = UIImagePickerController()
        ipc.delegate = self
        ipc.sourceType = .photoLibrary
        self.present(ipc, animated: true, completion: nil)
    }


    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        profileImageView.image = info[UIImagePickerControllerOriginalImage] as! UIImage?
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
    }

    @IBAction func uploadBtnTouchUpInside(_ sender: Any) {
        let imageData = UIImageJPEGRepresentation(profileImageView.image!, 1)
        if(imageData == nil){
            return
        }
        let uid = ManipulateUserDefaults.getUserid()
        let dict = ["uid":uid, "image":imageData] as [String : Any]
        do {
            let jsonDict = try JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted)
            let urlKey = DomainManager.DomainKeys.profileUpload.rawValue
            let url = DomainManager.readDomainPlist(key: urlKey)
            let completionHandler = {(_ date:Data?, _ resp:URLResponse?, _ error:Error?) -> Void
            in
                
            }
            KeliConnection.postMethodWithCompletionHandler(urlString: url, data: jsonDict, completionHandler: completionHandler)
            
        } catch {
            
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
  }
