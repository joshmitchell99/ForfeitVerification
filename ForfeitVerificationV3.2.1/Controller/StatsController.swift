//
//  StatsController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 15/12/2021.
//  Copyright © 2021 Ava Ford. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class StatsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let brain = Brain()
    
    let db = Firestore.firestore()
    var items: [Item] = []
    var idArray = [String]()

    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [brain.getEmptyItem()]
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        getUserIDs()
    }
    
    @IBAction func dismissPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func loadForfeitsPressed(_ sender: UIButton) {
        loadAllForfeitsFromFirestore()
    }
    
    @IBAction func displayForfeitsPressed(_ sender: UIButton) {
//        label.text = String(items)
//        print(items)
        countLabel.text = "Current count: \(items.count)"
        sortItems()
        myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statsCell", for: indexPath)
        let item = items[indexPath.row]
        print(item.id)
        cell.textLabel?.text = item.description
        cell.detailTextLabel?.text = "UserID: \(item.userId)\nAmount: $\(item.amount)\nDealine: \(item.deadline)\nStatus: \(item.getStatus())"
        return cell
    }
    
    
    
    
    
    func sortItems() {
        items.sort {
            $0.deadline.toDate() > $1.deadline.toDate()
        }
    }
    
    func getUserIDs() {
        db.collection("Users").getDocuments() { (querySnapshot, Error) in
            if let error = Error {
                print("Couldn't get the userIDs from Firestore :( ", error)
            } else {
                for document in querySnapshot!.documents {
                    print("...\(document.documentID) => \(document.data())")
                    let userId = document.documentID
                    if self.idArray.contains(userId) == false {
                        self.idArray.append(userId)
                    }
                }
            }
        }
    }
    
    func loadAllForfeitsFromFirestore() {
        items = []
        for id in idArray {
            print("ID iterating on is... ", id)
            db.collection("Users").document(id).collection("AllForfeits").getDocuments { (querySnapshot, Error) in
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
                            item.userId = id
                            item.amount = (data["amount"] as? Int)!
                            item.approved = (data["approved"] as? Bool)!
                            item.denied = (data["denied"] as? Bool)!
                            item.sentForConfirmation = (data["sentForConfirmation"] as? Bool)!
                            item.type = (data["type"] as? String)!
                            if item.type == "timelapse" {
                                item.image = UIImage(systemName: "timelapse")!.toString()!
                            }
                            self.items.append(item)
//                            self.myTableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    

}
