//
//  NumbersController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 23/04/2022.
//  Copyright © 2022 Ava Ford. All rights reserved.
//

import UIKit
import Firebase

class NumbersController: UIViewController {

    let db = Firestore.firestore()
    let brain = Brain()
    
    var forfeits: [Item] = []
    var totalUserCount = 0
    var totalChargedAmount = 0
    
    @IBOutlet weak var totalUserCountLabel: UILabel!
    @IBOutlet weak var totalForfeitCountLabel: UILabel!
    @IBOutlet weak var totalDonatedCountLabel: UILabel!
    @IBOutlet weak var totalWaitingForApprovalCountLabel: UILabel!
    @IBOutlet weak var totalApprovedCountLabel: UILabel!
    @IBOutlet weak var totalDeniedCountLabel: UILabel!
    @IBOutlet weak var totalUsersThatHaveSetAForfeitLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCurrentNumberOfUsersFromFS()
        loadForfeitStatsFromFS()
    }
    
    func loadCurrentNumberOfUsersFromFS() {
        db.collection("Users").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            let userCount = snap.documents.count
        }
    }
    
    func loadForfeitStatsFromFS() {
        //Total forfeits
        //Total amount verified/failed/waitingforconfirmation/left
        
        db.collection("Users").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            print("first snap document is ", snap.documents[0]["Forfeits"])
            
            totalUserCount = snap.documents.count
            
            for userDoc in snap.documents {
                db.collection("Users").document(userDoc.documentID).collection("Forfeits").getDocuments { snapshot, error in
                    guard let snap = snapshot else { return }
                    for item in snap.documents {
                        let newForfeit = brain.convertToItem(item)
                        forfeits.append(newForfeit)
                    }
                    refreshUI()
                }
            }
            
            return
            for userDoc in snap.documents {
                print("Userdoc is ", userDoc)
                if userDoc["Forfeits"] != nil {
                    for forfeit in userDoc["Forfeits"]! as! Array<DocumentSnapshot> {
                        print("forfeit is ", forfeit)
                    }
                }
            }
        }
        
        db.collection("Charged").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            for doc in snap.documents {
                if (doc["id"] as! String).contains("tube") == false {
                    totalChargedAmount += doc["amount"]! as! Int
                }
            }
        }
    }
    
    func refreshUI() {
        var approvedCount = 0, deniedCount = 0, paidCount = 0, waitingToBeVerifiedCount = 0
        for forfeit in forfeits {
            if forfeit.approved == true { approvedCount += 1 }
            if forfeit.denied == true { deniedCount += 1 }
            if forfeit.paid == true {
                paidCount += 1
            }
            if (forfeit.sentForConfirmation == true && forfeit.approved == false && forfeit.denied == false) {
                waitingToBeVerifiedCount += 1
            }
        }
        
        var usersThatHaveMadeAForfeit: [String] = []
        for forfeit in forfeits {
            if usersThatHaveMadeAForfeit.contains(forfeit.userId) == false {
                usersThatHaveMadeAForfeit.append(forfeit.userId)
            }
        }
        
        totalUserCountLabel.text = String(totalUserCount)
        totalForfeitCountLabel.text = String(forfeits.count)
        totalDonatedCountLabel.text = String(totalChargedAmount)
        totalWaitingForApprovalCountLabel.text = String(waitingToBeVerifiedCount)
        totalApprovedCountLabel.text = String(approvedCount)
        totalDeniedCountLabel.text = String(deniedCount)
        totalUsersThatHaveSetAForfeitLabel.text = String(usersThatHaveMadeAForfeit.count)
        
    }

}
