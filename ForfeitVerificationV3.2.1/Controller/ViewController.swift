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
    @IBOutlet weak var timeSubmittedLabel: UILabel!
    @IBOutlet weak var deadlineLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var howLongAgoSubmittedLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    
}

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var myTableView: UITableView!
    
    let brain = Brain()
    let db = Firestore.firestore()
    let storage = Storage.storage()
    var forfeits: [Item] = []
    var idArray = [String]()
    
    let other = Brain()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        brain.setDatesForNewUsers()
        
        myTableView.delegate = self
        myTableView.dataSource = self
        
        getUserIDs()
        
        myTableView.refreshControl = UIRefreshControl()
        myTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
    
    @IBAction func backPressed(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    /*
     Explanation:
     When the view loads, it collects all of the userIDs from Firestore, and stores them in an array
     It then loads the forfeits, iterating through the userID array
     
     */
        
    func getUserIDs() {
        print("Getting user IDs")
        db.collection("Users").getDocuments() { [self] (snapshot, error) in
            guard let snap = snapshot else { return }
            for user in snap.documents {
                let userId = user.documentID
                if self.idArray.contains(userId) == false {
                    self.idArray.append(userId)
                }
            }
            print("calling loadForfeits")
            loadForfeits()
        }
    }
    
    func loadForfeits() {
        forfeits = []
        for id in idArray {
            db.collection("Users").document(id).collection("Forfeits").getDocuments { [self] snapshot, error in
                guard let snap = snapshot else { return }
                for forfeit in snap.documents {
                    let item = brain.convertToItem(forfeit)
//                    print("new forfeit is ", item.description, item.amount, item.approved, item.denied, item.sentForConfirmation)
                    if item.approved ==  false && item.denied == false && item.sentForConfirmation == true {
                        print("appending forfeit", forfeits.count)
                        forfeits.append(item)
                    }
                }
                print("reloading tableview data!!!!!!!!!!", forfeits.count)
                forfeits.sort {
                    $0.deadline.toDate() > $1.deadline.toDate()
                }
                self.myTableView.reloadData()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forfeits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("Refreshing tableview")
        let cell = tableView.dequeueReusableCell(withIdentifier: "verificationCell", for: indexPath) as! VerificationTableViewCell
        let forfeit = forfeits[indexPath.row]
        cell.descriptionLabel.text = forfeit.description
        cell.timeSubmittedLabel.text = forfeit.timeSubmitted
        cell.deadlineLabel.text = forfeit.deadline
        cell.imageLabel.image = forfeit.image.toImage()
        cell.idLabel.text = forfeit.id
        cell.amountLabel.text = String(forfeit.amount)
        cell.emailLabel.text = forfeit.userId
        cell.howLongAgoSubmittedLabel.text = forfeit.deadline.toDate().getDaysSinceThenAsFormattedString()
                
        return cell
    }
    
    func playVideoWithID(_ id: String) {
        let asset = AVAsset(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/forfeitv3-2-1.appspot.com/o/\(id).mp4?alt=media&token=a21a9249-1f20-4dd3-a232-fad2699074c1")!)
        let item = AVPlayerItem(asset: asset)

        let player = AVPlayer(playerItem: item)
        let playerController = AVPlayerViewController()
        playerController.player = player
        present(playerController, animated: true) {
            print("PLAYING")
            player.play()
        }
    }
    
//    func playVideo(path: URL) {
//        let player = AVPlayer(url: path)
//        let controller=AVPlayerViewController()
//        controller.player=player
//        controller.view.frame = self.view.frame
//        self.view.addSubview(controller.view)
//        self.addChild(controller)
//        player.play()
//    }
    
//    func playVideoWithID(_ id: String) {
////        let player = AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/forfeitv3-2-1.appspot.com/o/\(id).mp4")!)
//        let player = AVPlayer(url: URL(string: "https://firebasestorage.googleapis.com/v0/b/forfeitv3-2-1.appspot.com/o/\(id).mp4?alt=media&token=a21a9249-1f20-4dd3-a232-fad2699074c1")!)
//        let controller=AVPlayerViewController()
//        controller.player=player
//        controller.view.frame = self.view.frame
//        self.view.addSubview(controller.view)
//        self.addChild(controller)
//        player.play()
//    }
    
    var prevSelectedIds: [String] = []
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = self.forfeits[indexPath.row]
        
        if item.type == "timelapse" && prevSelectedIds.contains(item.id) == false {
            prevSelectedIds.append(item.id)
            self.playVideoWithID(item.id)
            
//            let storageRef = Storage.storage().reference()
//            let videoRef = Storage.storage().reference(withPath: "\(item.id).mp4")
//
//            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
//            videoRef.getData(maxSize: 100 * 1024 * 1024) { data, error in
//              if let error = error {
//                print("Erros's ", error)
//              } else {
//                print("No error ", videoRef.fullPath)
////                self.playVideo(path: URL(string: "https://firebasestorage.googleapis.com/v0/b/forfeitv3-2-1.appspot.com/o/\(item.id).mp4")!)
////                self.playVideo(path: URL(string: videoRef.fullPath)!)
//              }
//            }
        }
        
        let alert = UIAlertController(title: "Approve or deny this?", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Approve", style: .default, handler: { action in
            self.forfeits.remove(at: indexPath.row)
            self.addForfeitToVerified(item)
            self.approveItem(item: item)
            self.myTableView.reloadData()
        }))
        alert.addAction(UIAlertAction(title: "Deny", style: .default, handler: { action in
            self.forfeits.remove(at: indexPath.row)
            self.sendFailedForfeit(email: item.userId, amount: item.amount, description: item.description, timeSubmitted: item.timeSubmitted)
            self.addForfeitToVerified(item)
            self.denyItem(item: item)
            self.myTableView.reloadData()
        }))
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { [self] action in
            if prevSelectedIds.contains(item.id) {
                prevSelectedIds.removeAll { str in
                    str == item.id
                }
            }
        }
        alert.addAction(cancelAction)
        if item.description != "DO NOT APPROVE/DENY!!!" {
            self.present(alert, animated: true, completion: nil)
        }
        self.myTableView.reloadData()
    }
    
    
    func sendFailedForfeit(email: String, amount: Int, description: String, timeSubmitted: String) {
//        let email = getUserId()
        db.collection("ToCharge").document(getRandomId(string: email)).setData([
            "amount"                :    amount,
            "email"                 :    email,
            "description"           :    description,
            "timeSubmitted"         :    timeSubmitted,
            "paid"                  :    false
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Successfully uploaded \(description) to ToCharge!")
            }
        }
    }
    func getRandomId(string: String) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return string + String((0..<10).map{ _ in letters.randomElement()! })
    }
    
    func addForfeitToVerified(_ item: Item) {
        db.collection("Verified").addDocument(data: [
            "amount"                :    item.amount,
            "approved"              :    item.approved,
            "deadline"              :    item.deadline,
            "denied"                :    item.denied,
            "description"           :    item.description,
            "id"                    :    item.id,
            "image"                 :    item.image,
            "paid"                  :    item.paid,
            "sentForConfirmation"   :    item.sentForConfirmation,
            "timeSubmitted"         :    item.timeSubmitted,
            "timelapse"             :    item.timelapseData,
            "type"                  :    item.type,
            "userId"                :    item.userId,
        ])
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
//        getUserIDs()
//        loadForfeits()
        self.myTableView.reloadData()
        DispatchQueue.main.async {
            self.myTableView.refreshControl?.endRefreshing()
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
