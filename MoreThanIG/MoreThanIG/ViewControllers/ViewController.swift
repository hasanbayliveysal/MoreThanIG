//
//  ViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 13.09.22.
//

import UIKit
import Firebase
import FirebaseAuth


class ViewController: UIViewController {

    @IBOutlet weak var myLogo: UIImageView!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var lineView: UIView!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
  
    
    @IBOutlet weak var eyeButtonn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedView))
        view.addGestureRecognizer(gestureRecognizer)
      
    }
    

    @IBAction func eyeClicked(_ sender: Any) {
        if eyeButtonn.currentImage == UIImage.init(systemName: "eye.slash"){
            passwordText.isSecureTextEntry = true
            eyeButtonn.setImage(UIImage.init(systemName: "eye"), for: .normal)
        }else{
            passwordText.isSecureTextEntry = false
            eyeButtonn.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        }
    }
    
    
    @objc func tappedView() {

        self.view.endEditing(true)

    }

    @IBAction func onClickLogin(_ sender: Any){
        if usernameText.text != "" && passwordText.text != "" {
            Auth.auth().signIn(withEmail: usernameText.text!, password: passwordText.text!) { data, error in
            if error != nil {
                self.makeAlert(title: "Error!", message: error?.localizedDescription ?? "Error")
            }else{
                
           
                self.loginUser()
                   }
                }
              }else{
            makeAlert(title: "Error!", message: "Please fill all fields")
        }
    }
    
    func loginUser() {
           Auth.auth().currentUser?.reload(completion: { (error) in
                      if let error = error {
                          self.makeAlert(title: "Error", message: error.localizedDescription)
                      } else {
                              if Auth.auth().currentUser != nil && Auth.auth().currentUser!.isEmailVerified {
                                  self.performSegue(withIdentifier: "toHomeVC", sender: nil)
                              } else {
                                  self.makeAlert(title: "Error!", message: "Please verify your account")
                                   }
                             }
                     })
    }
    
    @IBAction func forgetPasswordClicked(_ sender: Any) {
        Auth.auth().sendPasswordReset(withEmail: usernameText.text!) { error in
            if error != nil {
                self.makeAlert(title: "Error!", message: error?.localizedDescription ?? "Error")
            }else{
                self.makeAlert(title: "Reset link has been sent successfully", message: "Check your email")
            }
        }
    }
    
    func makeAlert (title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}

