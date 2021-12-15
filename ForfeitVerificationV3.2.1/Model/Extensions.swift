//
//  Extensions.swift
//  ForfeitV3.2
//
//  Created by Josh Mitchell on 9/27/20.
//  Copyright © 2020 Ava Ford. All rights reserved.
//

import UIKit

// Extensions to type String and UIImage that allow use to just put .toString() or .toImage() and convert them easily

extension String {
    func toImage() -> UIImage? {
        if let data = Data(base64Encoded: self, options: .ignoreUnknownCharacters){
            return UIImage(data: data)
        }
        return nil
    }
    
    func toDate() -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
        
        dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        dateFormatter.isLenient = true
        let date = dateFormatter.date(from:self)!
        return date
    }
}

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.jpegData(compressionQuality: 0.1)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}

extension Item {
    func getStatus() -> String {
        if self.approved == true {
            return "approved"
        } else if self.denied == true {
            return "denied"
        } else if self.paid == true {
            return "paid"
        } else if self.sentForConfirmation == true {
            return "sentForConfirmation"
        } else {
            return "Active"
        }
    }
}
