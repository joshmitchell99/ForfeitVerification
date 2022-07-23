//
//  VerifiedController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 02/05/2022.
//  Copyright © 2022 Ava Ford. All rights reserved.
//

import UIKit
import Firebase

class VerifiedController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var verifiedTableView: UITableView!
    var forfeits: [Item] = []
    let db = Firestore.firestore()
    let brain = Brain()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        verifiedTableView.delegate = self
        verifiedTableView.dataSource = self
        
        loadForfeitsFromFS()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forfeits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func loadForfeitsFromFS() {
        db.collection("Verified").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            for forfeit in snap.documents {
                let item = brain.convertToItem(forfeit)
                forfeits.append(item)
            }
            forfeits.sort {
                $0.type > $1.type
            }
            verifiedTableView.reloadData()
        }
    }

}
