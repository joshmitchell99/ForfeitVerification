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
    
    @IBOutlet weak var testLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCurrentNumberOfUsersFromFS()
        loadForfeitStatsFromFS()
    }
    
    func loadCurrentNumberOfUsersFromFS() {
        db.collection("Users").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            let userCount = snap.documents.count
            testLabel.text = "Number of users is: " + String(userCount)
        }
    }
    
    func loadForfeitStatsFromFS() {
        //Total forfeits
        //Total amount verified/failed/waitingforconfirmation/left
        
        db.collection("Users").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            print("first snap document is ", snap.documents[0]["Forfeits"])
            return
            for userDoc in snap.documents {
                db.collection("Users").document(userDoc.documentID).collection("Forfeits").getDocuments { snapshot, error in
                    print("Iterating over ", userDoc.documentID)
                    guard let snap = snapshot else { return }
                    for item in snap.documents {
                        let newForfeit = brain.convertToItem(item)
                        forfeits.append(newForfeit)
                    }
                    refreshUI()
                }
            }
        }
    }
    
    func refreshUI() {
        for forfeit in forfeits {
            var approvedCount = 0, deniedCount = 0, paidCount = 0, totalLost = 0, waitingToBeVerifiedCount = 0
            if forfeit.approved == true { approvedCount += 1 }
            if forfeit.denied == true { deniedCount += 1 }
            if forfeit.paid == true {
                paidCount += 1
                totalLost += forfeit.amount
            }
            if (forfeit.sentForConfirmation == true && forfeit.approved == false && forfeit.denied == false) {
                waitingToBeVerifiedCount += 1
            }
            testLabel.text = "\(approvedCount), \(deniedCount), \(paidCount), \(totalLost), \(waitingToBeVerifiedCount), \(forfeits.count)"
        }
    }

}
