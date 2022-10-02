//
//  SavedImagesViewController.swift
//  MoreThanIG
//
//  Created by Veysal on 16.09.22.
//

import UIKit
import CoreData

class SavedImagesViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var arrayImage = [UIImage]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getData()
    }
//    override func viewWillAppear(_ animated: Bool) {
//        getData()
//    }
    
    func getData(){
        arrayImage.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Saved")
                fetchRequest.returnsObjectsAsFaults = false
                do{
                    let results = try context.fetch(fetchRequest)
                    print("results \(results.count)")
                    if results.count > 0 {
                        for result in results as! [NSManagedObject] {
                            if let image = result.value(forKey: "savedImage") as? Data {
                               // DispatchQueue.main.async {
                                    self.arrayImage.append(UIImage(data: image)!)
                                //}
                                //
                             }
                            if let id = result.value(forKey: "id") as? UUID {
                                self.idArray.append(id)
                            }
                        }
                    }
                }catch{
                    //
                }
        tableView.reloadData()
        print("id array \(idArray.count)")
        print("image array \(arrayImage.count)")
    }
    

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayImage.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let appdelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appdelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Saved")
        let stringUUID = idArray[indexPath.row].uuidString
        fetchRequest.predicate = NSPredicate(format: "id = %@", stringUUID)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
                for result in results as! [NSManagedObject]{
                    if let id = result.value(forKey: "id") as? UUID {
                        if id == idArray[indexPath.row] {
                            context.delete(result)
                            idArray.remove(at: indexPath.row)
                            arrayImage.remove(at: indexPath.row)
                            tableView.reloadData()
                            
                            do{
                                try context.save()
                            }catch {
                                //
                            }
                        }
                        break
                    }
                }
            }
        }catch{
            //
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "savedcell", for: indexPath) as! SavedImagesCell
        cell.savedImage.image = arrayImage[indexPath.row]
        return cell
    }

}
