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
    @IBOutlet weak var totalForfeitsTodayLabel: UILabel!
    @IBOutlet weak var totalForfeitsThisWeekLabel: UILabel!
    @IBOutlet weak var totalForfeitsThisMonthLabel: UILabel!
    @IBOutlet weak var totalOnTheLineLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCurrentNumberOfUsersFromFS()
        loadForfeitStatsFromFS()
    }
    
    @IBAction func totalForfeitsPressed(_ sender: UIButton) {
        let forfeitsPresentationVC = K.mainStoryBoard.instantiateViewController(withIdentifier: "forfeitsPresentationController") as! ForfeitsPresentationController
        forfeitsPresentationVC.forfeits = forfeits
        present(forfeitsPresentationVC, animated:true)
    }
    
    @IBAction func forfeitsTodayPressed(_ sender: UIButton) {
        let forfeitsPresentationVC = K.mainStoryBoard.instantiateViewController(withIdentifier: "forfeitsPresentationController") as! ForfeitsPresentationController
        forfeitsPresentationVC.forfeits = pastDayCount
        present(forfeitsPresentationVC, animated:true)
    }
    
    @IBAction func forfeitsThisWeekPressed(_ sender: UIButton) {
        let forfeitsPresentationVC = K.mainStoryBoard.instantiateViewController(withIdentifier: "forfeitsPresentationController") as! ForfeitsPresentationController
        forfeitsPresentationVC.forfeits = pastWeekCount
        present(forfeitsPresentationVC, animated:true)
    }
    
    @IBAction func forfeitsThisMonthPressed(_ sender: UIButton) {
        let forfeitsPresentationVC = K.mainStoryBoard.instantiateViewController(withIdentifier: "forfeitsPresentationController") as! ForfeitsPresentationController
        forfeitsPresentationVC.forfeits = pastMonthCount
        present(forfeitsPresentationVC, animated:true)
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
    
    var approvedCount: [Item] = [], deniedCount: [Item] = [], paidCount: [Item] = [], waitingToBeVerifiedCount: [Item] = [], pastDayCount: [Item] = [], pastWeekCount: [Item] = [], pastMonthCount: [Item] = []
    var totalOnTheLine = 0
    func refreshUI() {
        approvedCount = []
        deniedCount = []
        paidCount = []
        waitingToBeVerifiedCount = []
        pastDayCount = []
        pastWeekCount = []
        pastMonthCount = []
        for forfeit in forfeits {
            if forfeit.approved == true { approvedCount.append(forfeit) }
            if forfeit.denied == true { deniedCount.append(forfeit) }
            if forfeit.paid == true {
                paidCount.append(forfeit)
            }
            if (forfeit.sentForConfirmation == true && forfeit.approved == false && forfeit.denied == false) {
                waitingToBeVerifiedCount.append(forfeit)
            }
            if forfeit.isInPastNumberOfDays(1) { pastDayCount.append(forfeit) }
            if forfeit.isInPastNumberOfDays(7) { pastWeekCount.append(forfeit) }
            if forfeit.isInPastNumberOfDays(30) { pastMonthCount.append(forfeit) }
            totalOnTheLine += forfeit.amount
        }
        
        var usersThatHaveMadeAForfeit: [String] = []
        for forfeit in forfeits {
            if usersThatHaveMadeAForfeit.contains(forfeit.userId) == false {
                usersThatHaveMadeAForfeit.append(forfeit.userId)
            }
        }
        
        totalUserCountLabel.text = String(totalUserCount)
//        totalForfeitCountLabel.text = String(forfeits.count)
        totalDonatedCountLabel.text = String(totalChargedAmount)
        totalWaitingForApprovalCountLabel.text = String(waitingToBeVerifiedCount.count)
        totalApprovedCountLabel.text = String(approvedCount.count)
        totalDeniedCountLabel.text = String(deniedCount.count)
        totalUsersThatHaveSetAForfeitLabel.text = String(usersThatHaveMadeAForfeit.count)
        totalForfeitsTodayLabel.text = String(pastDayCount.count)
        totalForfeitsThisWeekLabel.text = String(pastWeekCount.count)
        totalForfeitsThisMonthLabel.text = String(pastMonthCount.count)
        totalOnTheLineLabel.text = String(totalOnTheLine)
    }

}
