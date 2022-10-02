//
//  UploadPageViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 14.09.22.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseCore
import FirebaseFirestore



class UploadPageViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var commentText: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    var count = 0
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        imageView.addGestureRecognizer(gestureRecognizer)
        uploadButton.isEnabled = false
        activityIndicator.hidesWhenStopped = true
       
    }
    override func viewWillAppear(_ animated: Bool) {
        if imageView.image == UIImage.init(named: "select"){
            uploadButton.isEnabled = false
        }
    }
    
    @objc func onTapped(){
        let alert = UIAlertController(title: "Pick a photo", message: "Choose a picture from Library or take a photo with using Camera", preferredStyle: .actionSheet)
        let libaryButton = UIAlertAction(title: "Library", style: .default) { UIAlertAction in
            let library = self.imagePicker(sourceType: .photoLibrary)
            self.present(library, animated: true)
        }
        let cameraButton = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            let camera = self.imagePicker(sourceType: .camera)
            self.present(camera, animated: true)
        }
        alert.addAction(libaryButton)
        alert.addAction(cameraButton)
        present(alert, animated: true,completion: nil)
    }
 
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController{
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        return picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        uploadButton.isEnabled = true
    
    }
    @IBAction func onTappedUpload(_ sender: Any) {
        activityIndicator.startAnimating()
        var profileImage = ""
        let id = UUID()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaRef = storageRef.child("images")
        let mediaRef2 = storageRef.child("special")
        let imageRef2 = mediaRef2.child("userimage.png")
        let stringUUID = id.uuidString
        if let data = imageView.image?.jpegData(compressionQuality: 0.5){
            let imageRef = mediaRef.child("\(stringUUID).jpg")
            imageRef.putData(data, metadata: nil) { metadata, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Eroor")
                }else{
                    imageRef2.downloadURL { url, error in
                        if error == nil {
                            profileImage = url!.absoluteString
                        }
                    }
                    imageRef.downloadURL { [self] url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let firestoreDB = Firestore.firestore()
                            let firestorePosts = ["email": "\(Auth.auth().currentUser?.email ?? "")post",  "imageUrl" : imageUrl!, "postedBy" : Auth.auth().currentUser?.displayName ?? "", "postComment" : self.commentText.text ?? "", "Date" : Date(), "likes" : 0, "userPhotoUrl" : "\(Auth.auth().currentUser?.photoURL?.absoluteString ?? "")"]
                                               //   "heart" : "heartImage", "heart.fill" : "heart.fImage"]
                            firestoreDB.collection("Posts").addDocument(data: firestorePosts,completion: { error in
                                if error == nil {
                                    print("hello")
                                    self.imageView.image = UIImage.init(named: "select")
                                    self.commentText.text = ""
                                    self.tabBarController?.selectedIndex = 0
                                    self.activityIndicator.stopAnimating()
                                   
                                }
                            })
                        }else{
                            
                        }
                    }
                }
            }.resume()
        }
    }
    
    public func makeAlert (title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
}
