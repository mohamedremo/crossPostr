//
//  MediaType.swift
//  crosspostr
//
//  Created by Mohamed Remo on 19.02.25.
//
import Foundation

enum MediaType: String, Codable {
    case image = "image"
    case video = "video"
}

extension MediaType {
    init?(from string: String) {
        self.init(rawValue: string.lowercased()) // Wandelt automatisch um, falls der String gültig ist
    }
}
