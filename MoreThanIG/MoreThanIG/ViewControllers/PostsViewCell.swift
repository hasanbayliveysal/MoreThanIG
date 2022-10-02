//
//  PostsViewCell.swift
//  MoreThanIG
//
//  Created by Veysal on 16.09.22.
//

import UIKit
import Firebase
import FirebaseFirestore
import FirebaseStorage
import CoreData
import SDWebImage

class PostsViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var imagePosted: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var likeCountLabel: UILabel!
    var savedImageStr = ""
    var savedImage = UIImageView()
    override func awakeFromNib() {
        super.awakeFromNib()
        profileImage.clipsToBounds = true
        profileImage.layer.cornerRadius = 20
        //  profileImage.image = UIImage.init(named: "userimage")
        profileImage.contentMode = .scaleAspectFill
      //  getImageFromFirebase()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func onLikeClicked(_ sender: Any) {
        
        let fireStoreDatabase = Firestore.firestore()
//        fireStoreDatabase.collection("Posts").document(likeCountLabel.text!).collection("Likes").getDocuments { query, error in
//            if let error = error {
//                print(error.localizedDescription)
//            }else{
//                if query?.isEmpty != true {
//                    for document in query!.documents {
//                        if let document = document.get("likedBy") as? String {
//                            if document != "\(Auth.auth().currentUser?.email ?? "") like \(self.likeCountLabel.text!)" {
//                                let likedBy = ["likedBy" : "\(Auth.auth().currentUser?.email ?? "") like \(self.likeCountLabel.text!)"]
//                                fireStoreDatabase.collection("Posts").document(self.likeCountLabel.text!).collection("Likes").addDocument(data: likedBy as [String : Any]) { error in
//                                    if let error = error {
//                                        print("error\(error.localizedDescription)")
//                                    } else {
//                                       // break
//                                    }
//                                }
//                            }else {
//                                let likedBy = ["unlikedBy" : "\(Auth.auth().currentUser?.email ?? "") unlike \(self.likeCountLabel.text!)"]
//                                fireStoreDatabase.collection("Posts").document(self.likeCountLabel.text!).collection("Likes").addDocument(data: likedBy as [String : Any]) { error in
//                                    if let error = error {
//                                        print("error\(error.localizedDescription)")
//                                    } else {
//                                    //    break
//                                    }
//                                }
//                            }
//                        }
//                     }
//                }
//            }
//        }
//
        
     
//        fireStoreDatabase.collection("Posts").document(likeCountLabel.text!).collection("Likes").getDocuments { query, error in
//            if let error = error {
//                print(error.localizedDescription)
//            }else{
//
//                for document in query!.documents {
//
//                }
//            }
//        }
        
        
        if likeButton.currentImage == UIImage(systemName: "heart.fill") {
            if let likeCount = Int(likeLabel.text!) {
                let likeStore = ["likes" : likeCount - 1] as [String : Any]
                fireStoreDatabase.collection("Posts").document(likeCountLabel.text!).setData(likeStore, merge: true)
                likeButton.setImage(UIImage(systemName: "heart"), for: .normal)
            }
        }else {
            if let likeCount = Int(likeLabel.text!) {
                let likeStore = ["likes" : likeCount + 1] as [String : Any]
                fireStoreDatabase.collection("Posts").document(likeCountLabel.text!).setData(likeStore, merge: true)
                likeButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
    }
    @IBAction func onCommentClicked(_ sender: Any) {
        onComment?()
    }
    
    var onComment: (() -> Void)? = {}
    
    @IBAction func onSaveClicked(_ sender: Any) {
        fetchImagesFromFirestore()
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let newImage = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: context)
        let data = savedImage.image?.jpegData(compressionQuality: 0.5)
        let id = UUID()
        newImage.setValue(data, forKey: "savedImage")
        newImage.setValue(id, forKey: "id")
        do {
            try context.save()
        }catch{
            //
        }
        
    }
    
    func fetchImagesFromFirestore() {
        let firebaseDb = Firestore.firestore()
        firebaseDb.collection("Posts").document(likeCountLabel.text!).addSnapshotListener { DocumentSnapshot, error in
            if error == nil {
                if let image = DocumentSnapshot?.get("imageUrl") as? String {
                    self.savedImageStr = image
                }
            }
        }
        savedImage.sd_setImage(with: URL(string: savedImageStr))
    }
    
 
}
