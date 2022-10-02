//
//  RegisterViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 14.09.22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage


class RegisterViewController: UIViewController {

    @IBOutlet weak var eyeButton: UIButton!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var passwordtext: UITextField!
    @IBOutlet weak var passwordAgainText: UITextField!
    
   
    let image = UIImage.init(named: "userimage")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    public func makeAlert (title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            if title == "Email Verification has been sent succesfully" {
                self.performSegue(withIdentifier: "toLoginVC", sender: nil)
            }
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
 
    @IBAction func singupClicked(_ sender: Any) {
        
       
        if userName.text != "" && emailText.text != "" && passwordtext.text != "" && passwordAgainText.text != "" {
            if passwordtext.text == passwordAgainText.text {
                Auth.auth().createUser(withEmail: emailText.text!, password: passwordtext.text!) { data, error in
                    
                    
                    if error != nil {
                        self.makeAlert(title: "Error!",message: error?.localizedDescription ?? "Error")
                    }else{
                        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                        changeRequest!.displayName = self.userName.text
                        changeRequest?.commitChanges()
                            Auth.auth().currentUser?.sendEmailVerification { error in
                            if error != nil {
                                self.makeAlert(title: "Error!",message: error?.localizedDescription ?? "Error")
                            }else{
                               
                                self.makeAlert(title: "Email Verification has been sent succesfully",message: "Please check your email and verify then login your account")
                            }
                        }
                        
                    }
                        
                }
            }else{
                makeAlert(title: "Error!" ,message: "Passwords are not same")
            }
        }else{
            makeAlert(title: "Error!" ,message: "Please fill all fields")
        }
        
//        let storage = Storage.storage()
//        let storageRef = storage.reference()
//        let mediaRef = storageRef.child("ProfilePicture")
//        if let data = image?.jpegData(compressionQuality: 0.5) {
//            let imageRef = mediaRef.child("\(Auth.auth().currentUser?.email ?? "").jpg")
//            imageRef.putData(data,metadata: nil){ metadada, error in
//                if error != nil {
//                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Eroor")
//                }else{
//                    
//                }
//            }
//        }
    }
    
    
    @IBAction func onClickEyeButton(_ sender: Any) {
        if eyeButton.currentImage == UIImage.init(systemName: "eye.slash"){
            passwordtext.isSecureTextEntry = true
            passwordAgainText.isSecureTextEntry = true
            eyeButton.setImage(UIImage.init(systemName: "eye"), for: .normal)
        }else{
            passwordtext.isSecureTextEntry = false
            passwordAgainText.isSecureTextEntry = false
            eyeButton.setImage(UIImage.init(systemName: "eye.slash"), for: .normal)
        }
    }
}
