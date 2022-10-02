//
//  HomePageViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 14.09.22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import SDWebImage

var idArray = [String]()
var idForComment = ""
var idForImage = ""
var full = true
class HomePageViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    
    let storageRef = Storage.storage().reference()
  
    @IBOutlet weak var uitableView: UITableView!
    var usernameArray = [String]()
    var usercommentArray = [String]()
    var likeArray = [Int]()
    var userImage = [String]()
    var userProfileUrl = [String]()
    var emailArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.uitableView.delegate = self
            self.uitableView.dataSource = self
          
        }
      
    }
  
    override func viewWillAppear(_ animated: Bool) {
       
        getImageFromFirebase()
    }
    func getImageFromFirebase(){
        
        let firestoreDb = Firestore.firestore()
        firestoreDb.collection("Posts")
            .order(by: "Date", descending: true)
            .addSnapshotListener { QuerySnapshot, error in
                if error != nil{
                    print("error")
                }else{
                    if QuerySnapshot?.isEmpty != true {
                        self.usernameArray.removeAll()
                        self.usercommentArray.removeAll()
                        self.userImage.removeAll()
                        self.likeArray.removeAll()
                        idArray.removeAll()
                        self.userProfileUrl.removeAll()
                        for document in QuerySnapshot!.documents {
                            let documentID = document.documentID
                            idArray.append(documentID)
//                if let emailForProfile = document.get("emailForProfile") as? String {
//                    let mediaRef = self.storageRef.child("ProfilePicture")
//                    DispatchQueue.global(qos : .userInitiated).async {
//                        mediaRef.child("\(emailForProfile).jpg").downloadURL { url, error in
//                                if let error = error{
//                                    print(error.localizedDescription)
//                                }else{
//                                    print("got it yeah \(url!.absoluteString)")
//
//                                        self.userProfileUrl.append(url!.absoluteString)
//
//                                }
//                            }
//
//                    }
                       if let postedBy = document.get("postedBy") as? String {
                                    self.usernameArray.append(postedBy)
                                    if let postComment = document.get("postComment") as? String {
                                        self.usercommentArray.append(postComment)
                                        if let imageUrl = document.get("imageUrl") as? String {
                                            self.userImage.append(imageUrl)
                                            if let likes = document.get("likes") as? Int {
                                                self.likeArray.append(likes)
                                                if let userProfileUrl = document.get("userPhotoUrl") as? String {
                                                    print("userProfileUrl \(userProfileUrl)")
                                                    self.userProfileUrl.append(userProfileUrl)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        //}
                    }
                }
                self.uitableView.reloadData()
            }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = uitableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! PostsViewCell
            cell.imagePosted.sd_setImage(with: URL(string: userImage[indexPath.row]))
            cell.username.text = usernameArray[indexPath.row]
            cell.likeLabel.text = String(likeArray[indexPath.row])
            cell.commentLabel.text = usercommentArray[indexPath.row]
            cell.likeCountLabel.text = idArray[indexPath.row]
            cell.profileImage.sd_setImage(with: URL(string: userProfileUrl[indexPath.row]))
            cell.selectionStyle = .none
            cell.likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            cell.onComment = {
                idForComment = idArray[indexPath.row]
            }
    
        return cell
    }
    
}
