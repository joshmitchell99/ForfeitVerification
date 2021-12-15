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
    
}
