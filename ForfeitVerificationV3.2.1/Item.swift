//
//  Item.swift
//  ForfeitVerificationV3.2.1
//
//  Created by Josh Mitchell on 10/2/20.
//  Copyright © 2020 Ava Ford. All rights reserved.
//

import UIKit

class Item: Codable {
    var approved = false
    var deadline = ""
    var denied = false
    var description = ""
    var id = ""
    var image = ""
    var sentForConfirmation = false
    var timeSubmitted = ""
    var amount = -1
    var userId = ""
}

