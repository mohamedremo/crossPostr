//
//  Item.swift
//  crosspostr
//
//  Created by Mohamed Remo on 20.01.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
