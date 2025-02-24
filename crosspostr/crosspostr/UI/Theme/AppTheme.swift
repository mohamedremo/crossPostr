import SwiftUI

struct AppTheme {
    
    static let mainBackground: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [Color.main2, Color.main3, Color.main1]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    
    static let cardGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color.main1, location: 0.00),
            Gradient.Stop(color: Color.main2, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
        )
    
    static let cardTextColor: Color = Color(red: 0.7, green: 0.47, blue: 0.87).opacity(0.8)
}





