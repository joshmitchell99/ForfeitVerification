//
//  ForfeitsPresentationController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 03/05/2022.
//  Copyright © 2022 Ava Ford. All rights reserved.
//

import UIKit

class ForfeitCell: UITableViewCell {
    @IBOutlet weak var howLongAgoSubmittedLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var imageLabel: UIImageView!
}

class ForfeitsPresentationController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var forfeitTableView: UITableView!
    
    var forfeits: [Item] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        forfeitTableView.delegate = self
        forfeitTableView.dataSource = self
        
        forfeits.sort {
            $0.deadline.toDate().timeIntervalSince1970 > $1.deadline.toDate().timeIntervalSince1970
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forfeits.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "forfeitCell", for: indexPath) as! ForfeitCell
        let forfeit = forfeits[indexPath.row]
        cell.descriptionLabel.text = forfeit.description
        cell.idLabel.text = forfeit.id
        cell.amountLabel.text = String(forfeit.amount)
        cell.emailLabel.text = forfeit.userId
        cell.howLongAgoSubmittedLabel.text = forfeit.deadline.toDate().getDaysSinceThenAsFormattedString()
        
        if forfeit.image != "" {
            cell.imageLabel.image = forfeit.image.toImage()
        }
        
        return cell
    }

}
