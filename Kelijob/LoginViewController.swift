//
//  LoginViewController.swift
//  Kelijob
//
//  Created by netNORIMINGCONCEPTION on 2017/02/09.
//  Copyright © 2017年 flatLabel56. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var createAccountBtn: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var userNameField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        fbLoginButton.delegate = self
        signUpButton.isHidden = true
        userNameField.isHidden = true
        errorLabel.text = ""

        // Do any additional setup after loading the view.
    }

    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //ここでconfirmUidなどを行う
        if(error != nil){
            FBSDKLoginManager().logOut()
        }else if(result.isCancelled){
            FBSDKLoginManager().logOut()
        }else{
            //Handle login success
            let alertVC = UIAlertController.init(title: "Loading", message: "データをロードしています", preferredStyle: .alert)
            self.present(alertVC, animated: true, completion: nil)
            let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
            FIRAuth.auth()?.signIn(with: credential) { (user, error) in
                LoginManager.parseUserInfo()
                alertVC.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    /**
     名前の登録
     アカウント作成時に名前も登録したいが、changeRequestを使ってしかできないので
 　　*/
    func registerNameInFIR() {
        if let user = FIRAuth.auth()?.currentUser {
            let changeRequest = user.profileChangeRequest()
            changeRequest.displayName = userNameField.text
            changeRequest.commitChanges(completion: { error
                in
                if error != nil {
                    //ここのエラーはあえて補足しない
                } else {
                    //登録後のログイン処理
                    FIRAuth.auth()?.signIn(withEmail: self.emailField.text!, password: self.passwordField.text!) { (user, error) in
                        if(error == nil){
                            self.dismiss(animated: true, completion: nil)
                            LoginManager.parseUserInfo()
                            
                        }
                    }
                }
            } )
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func signInButtonTouchUpInside(_ sender: Any) {
        
        if(emailField.text!.characters.count == 0){
            errorLabel.text = "emailを入力してください。"
            return
        }
        if(passwordField.text!.characters.count == 0){
            errorLabel.text = "パスワードを入力してください。"
            return
        }

        errorLabel.text = "処理中です。"
        var alertController = UIAlertController()
        let completionHandler = {(alert:UIAlertController) -> Void
        in
            alertController = alert
        }
        AlertControllerManager.showAlertControllerWithoutTimer("Loading...", "データをロードしています", completionHandler)
        FIRAuth.auth()?.signIn(withEmail: emailField.text!, password: passwordField.text!) { (user, error) in
            //エラー表示とconfirm
            if(error == nil){
                LoginManager.parseUserInfo()
                //データをロードするのに最低5秒かかるので
                sleep(5)
                alertController.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            } else {
                alertController.dismiss(animated: true, completion: nil)
                AlertControllerManager.showAlertController("エラーが発生しました。", "もう一度やり直してください。", nil)
                self.errorLabel.text = ""
            }
        }
    }

    @IBAction func signUpButtonTouchUpInside(_ sender: Any) {
 
        if(emailField.text!.characters.count == 0){
            errorLabel.text = "emailを入力してください。"
            return
        }
        if(passwordField.text!.characters.count == 0){
            errorLabel.text = "パスワードを入力してください。"
            return
        }
        
        if(userNameField.text!.characters.count == 0){
            errorLabel.text = "ユーザー名を入力してください。"
            return
        }
        
        guard (isValidEmail(testStr: emailField.text!)) else {
            //エラー表示
            errorLabel.text = "正しいemailアドレスを入力してください。"
            return
        }
        
        guard (isValidPassword(candidate: passwordField.text!)) else {
            //エラー表示
            errorLabel.text = "パスワードは6~15文字で、大文字と数字を含めてください。"
            return
        }
        
        let email = emailField.text
        let password = passwordField.text
  
        FIRAuth.auth()?.createUser(withEmail: email!, password: password!) { (user, error) in
            //エラー表示とconfirm
            if(error == nil){
                AlertControllerManager.showAlertController("処理中です。", "しばらくお待ちください。", nil)
                self.registerNameInFIR()
            } else {
                print(String(describing: error))
                AlertControllerManager.showAlertController("エラーが発生しました。", "もう一度やり直してください。", nil)
            }
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        // print("validate calendar: \(testStr)")
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    func isValidPassword(candidate: String) -> Bool {
        let passwordRegex = "^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d).{6,15}$"
        
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: candidate)
    }

    @IBAction func createAccountBtnTouchUpInside(_ sender: Any) {
        signUpButton.isHidden = false
        signInButton.isHidden = true
        fbLoginButton.isHidden = true
        createAccountBtn.isHidden = true
        cancelButton.isHidden = false
        userNameField.isHidden = false
        errorLabel.text = ""
    }
    @IBAction func cancelButtonTouchUpInside(_ sender: Any) {
        signUpButton.isHidden = true
        signInButton.isHidden = false
        fbLoginButton.isHidden = false
        createAccountBtn.isHidden = false
        cancelButton.isHidden = true
        userNameField.isHidden = true
        errorLabel.text = ""
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
