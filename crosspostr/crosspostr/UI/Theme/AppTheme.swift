import SwiftUI

extension Color {
    static let mainPurple = Color("MainPurple", bundle: .main)
    static let darkPurple = Color("DarkPurple", bundle: .main)
}

struct AppTheme {
    
    static let mainGradient: LinearGradient = LinearGradient(
            gradient: Gradient(colors: [Color.mainPurple, Color.darkPurple]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    
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





