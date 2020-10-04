//
//  ViewController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 10/2/20.
//  Copyright © 2020 Ava Ford. All rights reserved.
//

import UIKit
import Firebase

class VerificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let db = Firestore.firestore()
    var forfeits: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        loadForfeits()
        self.myTableView.reloadData()
    }
    
    func loadForfeits() {
        
        // For some reason it only loads when you install the app...
        
        db.collection("Users").document("USERaak7LeZG3L8vvHBoyYyo").collection("Forfeits").getDocuments { (querySnapshot, Error) in
            if let error = Error {
                print("There was an issue retrieving data from Firestore", error)
            } else {
                
                if let snapshotDocuments = querySnapshot?.documents {
                    for doc in snapshotDocuments {
                        let data = doc.data()
                        
                        let item = Item()
                        
                        item.id = (data["id"] as? String)!
                        item.description = (data["description"] as? String)!
                        item.deadline = (data["deadline"] as? String)!
                        item.timeSubmitted = (data["timeSubmitted"] as? String)!
                        item.image = (data["image"] as? String)!
                        
                        print(item.id)
                        
                        self.forfeits.append(item)
                        
                        self.myTableView.reloadData()
                        
                        
                    }
                    
                }
            }
            
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forfeits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "verificationCell", for: indexPath) as! VerificationTableViewCell
        
        //print(forfeits[indexPath.row].image)
        
        cell.descriptionLabel.text = forfeits[indexPath.row].description
        cell.timeLabel.text = forfeits[indexPath.row].timeSubmitted
        cell.deadlineLabel.text = forfeits[indexPath.row].deadline
        cell.imageLabel.image = forfeits[indexPath.row].image.toImage()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = self.forfeits[indexPath.row]
        
        let alert = UIAlertController(title: "Approve or deny this?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { action in
            self.approveItem(item: item)
        }))
        alert.addAction(UIAlertAction(title: "Deny", style: .default, handler: { action in
            self.denyItem(item: item)
        }))
        
        self.present(alert, animated: true, completion: nil)
        
        self.forfeits.remove(at: indexPath.row)
        self.myTableView.reloadData()
        
    }
    
    func approveItem(item: Item) {
        db.collection("Users").document("USERaak7LeZG3L8vvHBoyYyo").collection("Forfeits").document(item.id).updateData([
            "approved" : true
        ]) { (error) in
            if let error = error {
                print("There was an error", error)
            }
        }
    }
    
    func denyItem(item: Item) {
        db.collection("Users").document("USERaak7LeZG3L8vvHBoyYyo").collection("Forfeits").document(item.id).updateData([
            "denied" : true
        ]) { (error) in
            if let error = error {
                print("There was an error", error)
            }
        }
    }
    
    
}
    
    

