//
//  UninstalledItemController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 7/23/21.
//  Copyright © 2021 Ava Ford. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase

class UninstalledItemController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    

    @IBOutlet weak var myTableView: UITableView!
    
    let brain = Brain()
    var items: [Item] = []
    let db = Firestore.firestore()
    var idArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        myTableView.delegate = self
        myTableView.dataSource = self
        
        getUserIDs()
//        loadUninstalledForfeitsFromFirestore()
        
        self.myTableView.reloadData()
    }
    
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    @IBAction func downloadPressed(_ sender: UIButton) {
        loadUninstalledForfeitsFromFirestore()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
        let item = items[indexPath.row]
        print(item.id)
        cell.textLabel?.text = item.description
        cell.detailTextLabel?.text = "\(item.userId), \(item.amount), \(item.deadline), \(item.getStatus())"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.items[indexPath.row]
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alert = UIAlertController(title: "Approve or deny this?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { action in
            self.items.remove(at: indexPath.row)
            // Remove from firestore also
            self.addToCharge(item)
            self.myTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Deny", style: .default, handler: { action in
            self.items.remove(at: indexPath.row)
            // Remove from firestore also
            self.myTableView.reloadData()
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    
    @IBAction func refreshPressed(_ sender: UIButton) {
//        loadUninstalledForfeitsFromFirestore()
        print("items 1 = ", items)
        items = filterExpiredActiveForfeits()
        print("items 2 = ", items)
        self.myTableView.reloadData()
    }
    
    func filterExpiredActiveForfeits() -> [Item] {
        var filtered: [Item] = []
        let currentDate = brain.getCurrentTime()
        
        for item in items {
            if item.deadline.toDate() < currentDate.toDate() && item.approved == false && item.denied == false { // && item.paid == false && item.sentForConfirmation == true {
                filtered.append(item)
            }
        }
        print("filtered = ", filtered)
        return filtered
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
    
    func loadUninstalledForfeitsFromFirestore() {
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
    
    func addToCharge(_ item: Item) {
        //this function takes in an item, and adds it to the ToCharge part of Firestore.
        print("about to charge ", item.description)
    }
    
}
