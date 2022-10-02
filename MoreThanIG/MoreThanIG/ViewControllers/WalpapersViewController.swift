//
//  WalpapersViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 15.09.22.
//

import UIKit
import SnapKit
import CoreData

struct APIResponse: Codable {
    let total: Int
    let total_pages: Int
    let results: [Result]
}
struct Result: Codable {
    let id: String
    let urls: URLS
}
struct URLS : Codable {
    let regular: String
}

class WalpapersViewController: UIViewController,UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegate {
    var Results: [Result] = []
    var result = ""
    var savedImage = UIImageView()
    private var collectionView : UICollectionView?
    let searchBar = UISearchBar()
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.addSubview(searchBar)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.frame.width-20, height: view.frame.width-20)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout:layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WalpaperCollectionViewCell.self, forCellWithReuseIdentifier: WalpaperCollectionViewCell.identifier)
        view.addSubview(collectionView)
        self.collectionView = collectionView
    }
  
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        collectionView?.snp.makeConstraints { make in
            make.top.equalTo(self.searchBar.safeAreaLayoutGuide.snp.bottom).offset(10)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        searchBar.showsCancelButton = true
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let text = searchBar.text {
            Results.removeAll(keepingCapacity: false)
            collectionView?.reloadData()
            fetchPhotos(searched: text)
            view.endEditing(true)
        }
        
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        Results.removeAll(keepingCapacity: false)
        collectionView?.reloadData()
        searchBar.text = ""
    }
    func fetchPhotos(searched: String) {
        let urlString = "https://api.unsplash.com/search/photos?page=1&per_page=30&query=\(searched)&client_id=uWadQKZ3m-lZ15Yg2b6NNBLxlzp7r6xxPJ3FlFGjP6g"

        guard let url = URL(string: urlString) else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do {
                let jsonResult = try JSONDecoder().decode(APIResponse.self, from: data)
                DispatchQueue.main.async {

                    
                    self.Results = jsonResult.results
                    self.collectionView?.reloadData()
                }
            } catch {
                print("error")
            }

        }
        task.resume()
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.savedImage.sd_setImage(with: URL(string: Results[indexPath.row].urls.regular))
            let alert = UIAlertController(title: "Do you want to dowload this image ?", message: "", preferredStyle: .actionSheet)
            let button = UIAlertAction(title: "Download", style: .default) { [self] UIAlertAction in
                let appdelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appdelegate.persistentContainer.viewContext
                let newImage = NSEntityDescription.insertNewObject(forEntityName: "Saved", into: context)
                let data = savedImage.image?.jpegData(compressionQuality: 0.1)
                newImage.setValue(data, forKey: "savedImage")
                newImage.setValue(UUID(), forKey: "id")
                do {
                    try context.save()
                   
                } catch {
                    //
                }
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(button)
            alert.addAction(cancel)
            present(alert, animated: true, completion: nil)
        
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Results.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let result = Results[indexPath.row].urls.regular
        guard  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WalpaperCollectionViewCell.identifier, for: indexPath) as? WalpaperCollectionViewCell else {
                    return UICollectionViewCell()
                }
        cell.configure(with: result)
        return cell
    }
}
