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
}

extension UIImage {
    func toString() -> String? {
        let data: Data? = self.jpegData(compressionQuality: 0.1)
        return data?.base64EncodedString(options: .endLineWithLineFeed)
    }
}
