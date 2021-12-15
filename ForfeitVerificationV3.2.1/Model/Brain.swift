//
//  Other.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 1/3/21.
//  Copyright © 2021 Ava Ford. All rights reserved.
//

import UIKit
import Firebase

struct Brain {
    
    func getCurrentTime() -> String {
        let currentDateTime = Date()
        
        let formatter = DateFormatter()
        formatter.isLenient = true
        formatter.timeStyle = .long
        formatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        
        let dateTimeString = formatter.string(from: currentDateTime)
        
        return dateTimeString
    }
    
    func getEmptyItem() -> Item {
        var item = Item()
        item.approved = false
//        item.deadline = "2021, MMM d, yyyy, h:mm a"
        item.denied = false
        item.description = "Loading..."
        item.id = "loading..."
        item.image = ""
        item.sentForConfirmation = false
//        item.timeSubmitted = ""
        item.type = "photo"
        item.amount = -1
        item.userId = "loading..."
        item.timelapseData = ""
        item.paid = false
        return item
    }
    
}
