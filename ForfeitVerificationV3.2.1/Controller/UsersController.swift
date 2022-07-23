//
//  UsersController.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 02/05/2022.
//  Copyright © 2022 Ava Ford. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    @IBOutlet weak var label: UILabel!
}

class User {
    var username = ""
    var dateCreated = ""
}

class UsersController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var usersTableView: UITableView!
    
    let db = Firestore.firestore()
    
    var users: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        usersTableView.delegate = self
        usersTableView.dataSource = self
        
        getUsernamesFromFS()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath) as! UserCell
        cell.label.text = users[indexPath.row].username
        
        return cell
    }
    
    func getUsernamesFromFS() {
        db.collection("Users").getDocuments { [self] snapshot, error in
            guard let snap = snapshot else { return }
            for doc in snap.documents {
                print("User is ", doc.documentID)
                let newUser = User()
                newUser.username = doc.documentID
                if let dateCreated = doc["dateCreated"] as? String {
                    newUser.dateCreated = dateCreated
                }
                users.append(newUser)
//                users.sort {
//                    $0.dateCreated.toDate().timeIntervalSince1970 > $1.dateCreated.toDate().timeIntervalSince1970
//                }
                usersTableView.reloadData()
            }
        }
    }

}
