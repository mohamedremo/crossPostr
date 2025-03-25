import SwiftUI

struct AppTheme {
    static let crosspostrBackground = Color(red: 28/255, green: 28/255, blue: 38/255)

    
    static let cardGradient = LinearGradient(
        stops: [
            Gradient.Stop(color: Color.main1, location: 0.00),
            Gradient.Stop(color: Color.main2, location: 1.00),
        ],
        startPoint: UnitPoint(x: 0.5, y: 0),
        endPoint: UnitPoint(x: 0.5, y: 1)
        )
    
    static let cardTextColor: Color = Color(red: 0.7, green: 0.47, blue: 0.87).opacity(0.8)
    
    
    // MARK: - Material Colors (Elegant & Modern)
    
    static let main1 = Color(red: 116/255, green: 70/255, blue: 255/255)     // Purple Accent
    static let main2 = Color(red: 82/255, green: 220/255, blue: 255/255)     // Teal Accent
    
    static let background = Color(red: 28/255, green: 28/255, blue: 38/255)  // Main dark background
    static let surface = Color(red: 36/255, green: 36/255, blue: 44/255)     // Cards / elevated surfaces
    
    static let primaryText = Color.white
    static let secondaryText = Color.gray
    
    static let borderColor = Color.white.opacity(0.05)
    static let shadowColor = Color.black.opacity(0.4)
    
    static let buttonGradient = LinearGradient(
        stops: [
            .init(color: main1, location: 0.0),
            .init(color: main2, location: 1.0)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let subtleGradientBackground = LinearGradient(
        gradient: Gradient(colors: [background, surface]),
        startPoint: .top,
        endPoint: .bottom
    )
}
