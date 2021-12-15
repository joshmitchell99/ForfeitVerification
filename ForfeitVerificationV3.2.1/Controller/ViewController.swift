//
//  ViewController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 10/2/20.
//  Copyright © 2020 Ava Ford. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import AVKit
import AVFoundation

class VerificationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imageLabel: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var statusLabel: UILabel!
    
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var forfeits: [Item] = []
    var idArray = [String]()
    
    let other = Brain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
//        other.chargeForfeits()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        getUserIDs()
//        loadForfeits()
        
        myTableView.refreshControl = UIRefreshControl()
        myTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        self.myTableView.reloadData()
    }
    
    /*
     Explanation:
     When the view loads, it collects all of the userIDs from Firestore, and stores them in an array
     It then loads the forfeits, iterating through the userID array
     
     */
    
    func getUserIDs() {
        statusLabel.text = "Getting user IDs"
        print("Getting user IDs")
        db.collection("Users").getDocuments() { [self] (querySnapshot, Error) in
            if let error = Error {
                print("Couldn't get the userIDs from Firestore :( ", error)
            } else {
                for document in querySnapshot!.documents {
                    print("...\(document.documentID) => \(document.data())")
                    statusLabel.text = "...\(document.documentID) => \(document.data())"
                    let userId = document.documentID
                    if self.idArray.contains(userId) == false {
                        self.idArray.append(userId)
                    }
                }
            }
        }
    }
    
    func loadForfeits() {
        statusLabel.text = "Loading Forfeits"
        print("Loading Forfeits")
        forfeits = []
        for id in idArray {
            print("ID iterating on is... ", id)
            statusLabel.text = "ID iterating on is... " + id
            db.collection("Users").document(id).collection("Forfeits").getDocuments { (querySnapshot, Error) in
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
                            item.approved = (data["approved"] as? Bool)!
                            item.denied = (data["denied"] as? Bool)!
                            item.type = (data["type"] as? String)!
                            if item.type == "timelapse" {
                                item.image = UIImage(systemName: "timelapse")!.toString()!
                            }
                            if item.approved == false && item.denied == false {
                                self.forfeits.append(item)
                                self.myTableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forfeits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Refreshing tableview")
        statusLabel.text = "Fully loaded"
        let cell = tableView.dequeueReusableCell(withIdentifier: "verificationCell", for: indexPath) as! VerificationTableViewCell
        cell.descriptionLabel.text = forfeits[indexPath.row].description
        cell.timeLabel.text = forfeits[indexPath.row].timeSubmitted
        cell.deadlineLabel.text = forfeits[indexPath.row].deadline
        cell.imageLabel.image = forfeits[indexPath.row].image.toImage()
        cell.idLabel.text = forfeits[indexPath.row].id
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.forfeits[indexPath.row]
        
//        if item.type == "timelapse" {
//            let storageRef = Storage.storage().reference()
//            let videoRef = Storage.storage().reference(withPath: "\(item.id).mp4")
//            print("Description of video ", videoRef.debugDescription)
//
//            // Create a reference to the file you want to download
//            let islandRef = storageRef.child("images.mp4")
//
//            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//            videoRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
//              if let error = error {
//                print("Erros's ", error)
//              } else {
//                print("No error ", videoRef.fullPath)
//                self.playVideo(path: URL(string: videoRef.fullPath)!)
//              }
//            }
//        }
//
        
        let alert = UIAlertController(title: "Approve or deny this?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { action in
            self.forfeits.remove(at: indexPath.row)
            self.approveItem(item: item)
            self.myTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Deny", style: .default, handler: { action in
            self.forfeits.remove(at: indexPath.row)
            self.denyItem(item: item)
            self.myTableView.reloadData()
        }))
        if item.description != "DO NOT APPROVE/DENY!!!" {
            self.present(alert, animated: true, completion: nil)
        }
        self.myTableView.reloadData()
    }
    
    
    func approveItem(item: Item) {
        print("approving item")
        db.collection("Users").document(item.userId).collection("Forfeits").document(item.id).updateData([
            "approved" : true
        ]) { (error) in
            if let error = error {
                print("There was an error", error)
            }
        }
    }
    func denyItem(item: Item) {
        print("denying item")
        db.collection("Users").document(item.userId).collection("Forfeits").document(item.id).updateData([
            "denied" : true
        ]) { (error) in
            if let error = error {
                print("There was an error", error)
            }
        }
    }
    
    
    
    //MARK: - PULL TO REFRESH
    @objc func didPullToRefresh() {
        statusLabel.text = "refreshed"
//        getUserIDs()
        loadForfeits()
        self.myTableView.reloadData()
        DispatchQueue.main.async {
            self.myTableView.refreshControl?.endRefreshing()
        }
    }
    
    
    func playVideo(path: URL) {
        
        let asset = AVAsset(url: path)
        let item = AVPlayerItem(asset: asset)
        
        let player = AVPlayer(playerItem: item)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            print("PLAYING")
            player.play()
        }
    }
    
    
    
    
    
    
    
    
    
    
}



















































//        db.collection("Users").document("joshmitchell10@gmail.com").collection("Forfeits").getDocuments { (snapshot, error) in
//            if let err = error {
//                debugPrint("Error updating items from firestore", err)
//            } else {
//                print("in it...")
//                guard let snap = snapshot else { return }
//                let Items = [Item]()
//                for document in snap.documents {
//
//                    let data = document.data()
//                    let id = data["id"] as? String ?? ""
//                    print("id = ", id)
//                    let approved = data["approved"] as? Bool ?? false
//                    let denied = data["denied"] as? Bool ?? false
//                    for item in Items {
//                        if item.id == id {
//                            item.approved = approved
//                            item.denied = denied
//                        }
//                        print(item)
//                    }
//                }
//                //self.myTableView.reloadData()  //REMOVE COMMENT IF THIS FUCKS STUFF UP. Only uncommented as it makes the payment page be called twice.
//            }
//        }
