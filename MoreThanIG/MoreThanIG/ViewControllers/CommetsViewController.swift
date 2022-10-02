//
//  CommetsViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 16.09.22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class CommetsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var commentTableView: UITableView!
    @IBOutlet weak var commentLabel: UITextField!
    let firestoreDB = Firestore.firestore()
    var usernameArray = [String]()
    var commentArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        commentTableView.delegate = self
        commentTableView.dataSource = self
        getComment()
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(onTappedView))
        view.addGestureRecognizer(gestureRecognizer)
    }
    
    @objc  func onTappedView() {
        view.endEditing(true)
    }
    func getComment(){
        firestoreDB.collection("Posts").document(idForComment).collection("CommentEachPhoto")
            .order(by: "Date", descending: true)
            .addSnapshotListener { QuerySnapshot, error in
            if QuerySnapshot?.isEmpty != true {
                self.usernameArray.removeAll(keepingCapacity: false)
                self.commentArray.removeAll(keepingCapacity: false)
                for document in QuerySnapshot!.documents {
                    if let comment = document.get("Comment") as? String {
                        self.commentArray.append(comment)
                        if let username = document.get("Username") as? String{
                            self.usernameArray.append(username)
                        }
                    }
                }
            }
            self.commentTableView.reloadData()
        }
    }
        @IBAction func postClicked(_ sender: Any) {
            if commentLabel.text != "" {
                let firestoreComments = ["Username" : Auth.auth().currentUser?.displayName ?? "", "Comment" : commentLabel.text!, "Date" : Date()] as [String:Any]
                firestoreDB.collection("Posts").document(idForComment).collection("CommentEachPhoto").addDocument(data: firestoreComments){ error in
                    if error == nil {
                        self.commentLabel.text = ""
                    }
                }
            }
            getComment()
            
        }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernameArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        var content = cell.defaultContentConfiguration()
        content.text = "\(usernameArray[indexPath.row]) : \(commentArray[indexPath.row])"
        cell.contentConfiguration = content
        return cell
    }
    
    
}
