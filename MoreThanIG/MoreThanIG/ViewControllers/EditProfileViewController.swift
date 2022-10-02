//
//  EditProfileViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 24.09.22.
//

import UIKit
import FirebaseAuth

class EditProfileViewController: UIViewController {

    let auth = Auth.auth().currentUser
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var username: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        username.text = auth?.displayName
        email.text = auth?.email
    }
    

    @IBAction func onTapSave(_ sender: Any) {
        auth?.updatePassword(to: password.text!) { error in
            if let error = error {
                self.makeAlert(title: "Error", message: error.localizedDescription)
            }else {
                self.makeAlert(title: "Password is changed sucsessfully", message: "")
            }
        }
       
        
    }
  
  

    @IBAction func onTapBack(_ sender: Any) {
      
        performSegue(withIdentifier: "toProfileVC", sender: nil)
        self.tabBarController?.selectedIndex = 3
    }
    
    public func makeAlert (title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default) { action in
            if title == "Password is changed sucsessfully" {
                self.performSegue(withIdentifier: "toProfileVC", sender: nil)
            }
        }
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
}
