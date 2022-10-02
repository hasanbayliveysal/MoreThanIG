//
//  ProfilePageViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 14.09.22.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore

class ProfilePageViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var selectedIndex = 0

    var profilePhoto = ""
    var userPosts = [String]()
    
    private var collectionView : UICollectionView?
    private var collectionViewPosts : UICollectionView?
    var letterArray = [UIImage](arrayLiteral: UIImage.init(systemName: "m.circle")!,UIImage.init(systemName: "o.circle")!,UIImage.init(systemName: "r.circle")!,UIImage.init(systemName: "e.circle")!,UIImage.init(systemName: "t.circle")!,UIImage.init(systemName: "h.circle")!,UIImage.init(systemName: "a.circle")!,UIImage.init(systemName: "n.circle")!,UIImage.init(systemName: "i.circle")!,UIImage.init(systemName: "g.circle")!)
    
    private lazy var addImageButton: UIButton = {
        let button = UIButton()
        view.addSubview(button)
        button.setImage(UIImage.init(systemName: "plus"), for: .normal)
        button.addTarget(self, action: #selector(onTapAddImage), for: .touchUpInside)
        return button
    }()
    
    private lazy var actionButton : UIButton = {
        let button = UIButton()
        view.addSubview(button)
        button.setImage(UIImage.init(systemName: "list.dash"), for: .normal)
        button.addTarget(self, action: #selector(onClickAction), for: .touchUpInside)
        return button
    }()
    private lazy var Image: UIImageView = {
        let image = UIImageView()
        view.addSubview(image)
        image.clipsToBounds = true
        image.layer.cornerRadius = 40
        image.backgroundColor = .white
        image.contentMode = .scaleAspectFill
        image.image = UIImage.init(named: "userimage")
        return image
    }()
    private lazy var usernameLabel : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = Auth.auth().currentUser?.displayName
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    private lazy var useremailLabel : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = Auth.auth().currentUser?.email
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        return label
    }()
    let mySegmentedControl = UISegmentedControl (items: ["User Images", "Liked Images"])
   
    private lazy var editProfile : UIButton = {
        let button = UIButton()
        view.addSubview(button)
        button.setTitle("edit profile", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.layer.cornerRadius = 10
        button.backgroundColor = .init(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.1)
        button.layer.borderWidth = 5
        button.layer.borderColor = .init(gray: 1, alpha: 0.9)
        button.addTarget(self, action: #selector(onClickEdit), for: .touchUpInside)
        return button
    }()
    
    private lazy var postsCount : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = String(userPosts.count)
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private lazy var  followerCount : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = "99.9B"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private lazy var  followingCount : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = "99"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        return label
    }()
    private lazy var  postsLabel : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = "Posts"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private lazy var  followerLabel : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = "Followers"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    private lazy var  followingLabel : UILabel = {
        let label = UILabel()
        view.addSubview(label)
        label.text = "Following"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        return label
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
      
        getImageFromFirebase()
       
        let storageRef = Storage.storage().reference()
        let mediaRef = storageRef.child("special")
        let imageRef = mediaRef.child("userimage.png")
     
            imageRef.downloadURL { url, error in
                if error != nil {
                    print(error!.localizedDescription)
                 //   print("okdfws \(Auth.auth().currentUser?.photoURL)")
                }else {
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges()
                //    print("ok \(Auth.auth().currentUser?.photoURL)")
                }
                
            
        }
       
        
       
       
        
        
        // Collection view
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 80, height: 80)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(LettersCollectionViewCell.self, forCellWithReuseIdentifier: LettersCollectionViewCell.identifier)
        view.addSubview(collectionView)
        self.collectionView = collectionView
        
        //Collection view Posts
        let layoutPosts = UICollectionViewFlowLayout()
        layoutPosts.scrollDirection = .horizontal
        layoutPosts.itemSize = CGSize(width: view.bounds.width-20, height: view.bounds.width-20)
        let collectionViewPosts = UICollectionView(frame: .zero, collectionViewLayout: layoutPosts)
        collectionViewPosts.delegate = self
        collectionViewPosts.dataSource = self
        collectionViewPosts.register(PostsCollectionViewCell.self, forCellWithReuseIdentifier: PostsCollectionViewCell.identifier)
        view.addSubview(collectionViewPosts)
        self.collectionViewPosts = collectionViewPosts
        
        
        // Segmented Control
        mySegmentedControl.selectedSegmentIndex = 0
        mySegmentedControl.addTarget(self, action: #selector(valueChanged(_ :)), for: .valueChanged)
        self.view.addSubview(mySegmentedControl)
        actionButton.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
        }
        self.collectionViewPosts?.snp.makeConstraints({ make in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(10)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-10)
            make.top.equalTo(mySegmentedControl.snp.bottom).offset(5)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
        })
        editProfile.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalTo(useremailLabel.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.width.equalTo(30)
        }
        usernameLabel.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(10)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
          
        }
        mySegmentedControl.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-20)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
        }
        Image.snp.makeConstraints { make in
            make.top.equalTo(usernameLabel.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
            make.width.height.equalTo(80)
        }
        useremailLabel.snp.makeConstraints { make in
            make.top.equalTo(Image.safeAreaLayoutGuide.snp.bottom).offset(20)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(20)
          
        }
        self.collectionView?.snp.makeConstraints { make in
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left)
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right)
            make.top.equalTo(editProfile.safeAreaLayoutGuide.snp.bottom).offset(15)
            make.bottom.equalTo(mySegmentedControl.safeAreaLayoutGuide.snp.top).offset(-20)
        }
        followingCount.snp.makeConstraints { make in
            make.right.equalTo(view.safeAreaLayoutGuide.snp.right).offset(-40)
            make.top.equalTo(Image.safeAreaLayoutGuide.snp.top).offset(20)
        }
        followingLabel.snp.makeConstraints { make in
            make.centerX.equalTo(followingCount.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(followingCount.safeAreaLayoutGuide.snp.bottom).offset(3)
        }
        followerCount.snp.makeConstraints { make in
            make.right.equalTo(followingCount.safeAreaLayoutGuide.snp.left).offset(-60)
            make.top.equalTo(Image.safeAreaLayoutGuide.snp.top).offset(20)
        }
        followerLabel.snp.makeConstraints { make in
            make.centerX.equalTo(followerCount.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(followerCount.safeAreaLayoutGuide.snp.bottom).offset(3)
        }
        postsCount.snp.makeConstraints { make in
            make.right.equalTo(followerCount.safeAreaLayoutGuide.snp.left).offset(-60)
            make.top.equalTo(Image.safeAreaLayoutGuide.snp.top).offset(20)
        }
        postsLabel.snp.makeConstraints { make in
            make.centerX.equalTo(postsCount.safeAreaLayoutGuide.snp.centerX)
            make.top.equalTo(postsCount.safeAreaLayoutGuide.snp.bottom).offset(3)
        }
        addImageButton.snp.makeConstraints { make in
            make.top.equalTo(Image.snp.bottom).offset(-15)
            make.left.equalTo(view.safeAreaLayoutGuide.snp.left).offset(65)
            make.width.height.equalTo(25)
        }
       
    }
    
    @objc func valueChanged (_ sender : UISegmentedControl) {
        if mySegmentedControl.selectedSegmentIndex == 0 {
            collectionViewPosts!.reloadData()
           selectedIndex = 0
        }
        if mySegmentedControl.selectedSegmentIndex == 1 {
            collectionViewPosts!.reloadData()
           selectedIndex = 1
        }
    }
    
    @objc func onClickEdit() {
        self.performSegue(withIdentifier: "toEditVC", sender: nil)
    }
    
    func getImageFromFirebase(){
        let firestoreDB = Firestore.firestore()
        firestoreDB.collection("UserProfilePhoto")
            .order(by: "date", descending: false)
            .addSnapshotListener { QuerySnapshot, Error in
            if Error != nil {
                self.makeAlert(title: "Error", message: Error?.localizedDescription ?? "Eroor")
            }else{
                if QuerySnapshot?.isEmpty != true {
                    for document in QuerySnapshot!.documents {
                        if let email = document.get("email"){
                            if email as! String == "\(Auth.auth().currentUser?.email ?? "")profile" {
                                if let image = document.get("image") as? String {
                                    self.profilePhoto = image
                                    self.Image.sd_setImage(with: URL(string: self.profilePhoto))
                                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                    changeRequest?.photoURL = URL(string: self.profilePhoto)
                                    changeRequest?.commitChanges()
                                    firestoreDB.collection("Posts").addSnapshotListener { query, error in
                                        if error != nil {
                                            self.makeAlert(title: "Error", message: error!.localizedDescription)
                                        }else{
                                            if query?.isEmpty != true {
                                                for document in query!.documents {
                                                    if let email = document.get("email") as? String {
                                                        if email == "\(Auth.auth().currentUser?.email ?? "")post" {
                                                            let profilePhoto = ["userPhotoUrl" :  self.profilePhoto]
                                                            firestoreDB.collection("Posts").document(document.documentID).setData(profilePhoto as [String : Any], merge: true)
                                                            
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        
        fetchUserPostsFromFirebase()

    }
    
    
    @objc func onClickAction(){
        let alert = UIAlertController(title: "MoreThanIG", message: "All rights reserved", preferredStyle: .actionSheet)
    
        let savedImageBtn = UIAlertAction(title: "Saved Images", style: .default) { UIAlertAction in
            self.performSegue(withIdentifier: "toSavedVC", sender: nil)
        }
        let editProfile = UIAlertAction(title: "Edit Profile", style: .default) { UIAlertAction in
            self.performSegue(withIdentifier: "toEditVC", sender: nil)
        }
        let aboutusBtn = UIAlertAction(title: "About us", style: .default)
        let supportBtn = UIAlertAction(title: "Support", style: .default)
        let cancelBtn = UIAlertAction(title: "Cancel", style: .cancel)
        let logoutBtn = UIAlertAction(title: "Log out", style: .default) { UIAlertAction in
            do{
                try Auth.auth().signOut()
                self.performSegue(withIdentifier: "toLoginVC", sender: nil)
            } catch {
                       print(error)
                   }
        }
        alert.addAction(savedImageBtn)
        alert.addAction(editProfile)
        alert.addAction(aboutusBtn)
        alert.addAction(supportBtn)
        alert.addAction(logoutBtn)
        alert.addAction(cancelBtn)
        self.present(alert, animated: true,completion: nil)
    }
    
    @objc func onTapAddImage() {
        let alert = UIAlertController(title: "Pick a photo", message: "Choose a picture from Library or take a photo with using Camera", preferredStyle: .actionSheet)
        let libaryButton = UIAlertAction(title: "Library", style: .default) { UIAlertAction in
            let library = self.imagePicker(sourceType: .photoLibrary)
            self.present(library, animated: true)
        }
        let cameraButton = UIAlertAction(title: "Camera", style: .default) { UIAlertAction in
            let camera = self.imagePicker(sourceType: .camera)
            self.present(camera, animated: true)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addAction(libaryButton)
        alert.addAction(cameraButton)
        alert.addAction(cancel)
        present(alert, animated: true,completion: nil)
      
        
    }
    func addImageFirebase() {
    //    let id = UUID()
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let mediaRef = storageRef.child("ProfilePicture")
     //   let stringUUId = id.uuidString
        if let data = Image.image?.jpegData(compressionQuality: 0.5) {
            let imageRef = mediaRef.child("\(Auth.auth().currentUser?.email ?? "").jpg")
            imageRef.putData(data,metadata: nil){ metadada, error in
                if error != nil {
                    self.makeAlert(title: "Error", message: error?.localizedDescription ?? "Eroor")
                }else{
                    imageRef.downloadURL { url, error in
                        if error == nil {
                            let imageUrl = url?.absoluteString
                            let firestoreDB = Firestore.firestore()
                            let firestoreUserPhoto = ["email" : "\(Auth.auth().currentUser?.email ?? "")profile", "image" : imageUrl ?? "", "date" : Date()]
                            firestoreDB.collection("UserProfilePhoto").addDocument(data: firestoreUserPhoto) { error in
                                if let error = error {
                                    self.makeAlert(title: "Error", message: error.localizedDescription)
                                }else{
                                    print("add sucsesly")
                                }
                            }
                            }else{
                                self.makeAlert(title: "Error", message: error!.localizedDescription)
                            }
                   
                    }
                }
            }.resume()
        }
    }
    
    func imagePicker(sourceType: UIImagePickerController.SourceType) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = sourceType
        return picker
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        Image.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        addImageFirebase()
       
       
    }
    
    public func makeAlert (title: String,message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okButton)
        present(alert, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == self.collectionView {
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LettersCollectionViewCell.identifier, for: indexPath) as? LettersCollectionViewCell else {
                return UICollectionViewCell()
            }
            let image = letterArray[indexPath.row]
            // imageView.image = nil
            cell.configure(with: image)
            return cell
        } else {
            guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostsCollectionViewCell.identifier, for: indexPath) as? PostsCollectionViewCell else {
                return UICollectionViewCell()
            }
            if selectedIndex == 0 {
                let image = userPosts[indexPath.row]
                cell.configure(with: image)
            } else {
                //let image = letterArray[indexPath.row]
                //cell.configure(with: ".")
            }
            return cell
       }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == self.collectionView {
            return letterArray.count
        }
        else{
            if selectedIndex == 0 {
                return userPosts.count
            } else {
                return 0
            }
        }
    }
    
    func fetchUserPostsFromFirebase() {
        userPosts.removeAll()
        let firebaseDB = Firestore.firestore()
        firebaseDB.collection("Posts")
            .order(by: "Date", descending: true)
            .addSnapshotListener { QuerySnapshot, Error in
                if Error != nil {
                    self.makeAlert(title: "Error", message: Error?.localizedDescription ?? "Eroor")
                } else {
                    if QuerySnapshot?.isEmpty != true {
                        for document in QuerySnapshot!.documents {
                            if let email = document.get("email"){
                                if email as! String == "\(Auth.auth().currentUser?.email ?? "")post" {
                                    if let image = document.get("imageUrl") as? String{
                                        self.userPosts.append(image)
                                    }
                                }
                            }
                        }
                    }
                }
                self.postsCount.text = String(self.userPosts.count)
                self.collectionViewPosts?.reloadData()
            }
    }
}

class LettersCollectionViewCell : UICollectionViewCell {
    
    static let identifier = "cell"
    private let imageView : UIImageView = {
        let image = UIImageView()
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func configure(with Image: UIImage){

        self.imageView.image = Image
    }
    
}

class PostsCollectionViewCell : UICollectionViewCell {
    
    static let identifier = "cell"
    private let imageView : UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        return image
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
       fatalError()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    func configure(with Image: String){
  
        self.imageView.sd_setImage(with: URL(string: Image))
    }
    
}
