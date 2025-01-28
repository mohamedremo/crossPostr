//
//  AppTheme.swift
//  crosspostr
//
//  Created by Mohamed Remo on 28.01.25.
//
import SwiftUI


struct AppTheme {
    static let blueGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.71, green: 0.71, blue: 0.71),
            Color(red: 0.32, green: 0, blue: 1),
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenGradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.71, green: 0.71, blue: 0.71),
            Color(red: 0, green: 1, blue: 0.32),
        ]),
        startPoint: .top,
        endPoint: .bottom
    )
}
