//
//  OnBoardingScreen.swift
//  crosspostr
//
//  Created by Mohamed Remo on 22.01.25.
//
import SwiftUI

struct OnBoardingScreen: View {
    @State var gradient: LinearGradient = LinearGradient(
        gradient: Gradient(colors: [
            Color(red: 0.71, green: 0.71, blue: 0.71),
            Color(red: 0.32, green: 0, blue: 1),
        ]),
        startPoint: .top,
        endPoint: .bottom
    )

    var body: some View {
        ZStack {
            gradient
            
            VStack {
                Spacer()
                InfoBox()
                    .padding(.bottom, 120)
                CustomButton()
                    .padding(.vertical, 30)
                
                HStack {
                    Image(.lineLeft)
                    Text("or login with")
                        .font(.footnote)
                    Image(.lineRight)
                }
                
                HStack {
                    SocialMediaButton(image: .google, action: {
                        
                    })
                    SocialMediaButton(image: .apple, action: {
                        
                    })
                }
                Spacer()
            }
        }
        .ignoresSafeArea()
    }
    
}

// MARK: - INFOBOX
struct InfoBox: View {
    @State var gradient: LinearGradient = LinearGradient(
        colors: [.purple, .gray], startPoint: .bottomTrailing,
        endPoint: .leading)
    var body: some View {
        ZStack {
            gradient  // HINTERGRUND
            HStack {
                VStack {
                    Spacer()
                    Text("💆")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-3)
                }
                Spacer()
                VStack {
                    Text("☀️")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-18)
                    Spacer()
                    Text("🏖️")
                        .font(Font.custom("SF Pro", size: 60))
                        .padding(-15)
                }
            }
            VStack {
                Text("crossPostr.")
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .shadow(radius: 3)
                    .padding(-10)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
                Text("Deine Storys. Überall.")
                    .fontWeight(.thin)
                    .font(.headline)
                    .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
            }
        }
        .frame(width: 339, height: 143)
        .cornerRadius(30)
        .shadow(color: .black.opacity(0.25), radius: 2, x: 0, y: 4)
    }
}

// MARK: - CustomButton
struct CustomButton: View {
    var body: some View {
        Button {
            
        } label: {
            ZStack {
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(width: 147, height: 50)
                    .background(
                        LinearGradient(
                            stops: [
                                Gradient.Stop(
                                    color: .white.opacity(0.9), location: 0.00),
                                Gradient.Stop(
                                    color: .white.opacity(0.6), location: 1.00),
                            ],
                            startPoint: UnitPoint(x: 0.5, y: 0),
                            endPoint: UnitPoint(x: 0.5, y: 1)
                        )
                    )
                    .cornerRadius(20)
                Text("Jetzt Starten!")
                    .foregroundStyle(.black)
                    .font(
                        .system(size: 18, weight: .semibold, design: .rounded))
            }
        }
    }
}

// MARK: - SocialMediaButton
struct SocialMediaButton: View {
    @State var image: ImageResource
    var action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Rectangle()
                .foregroundColor(.clear)
                .frame(width: 60, height: 50)
                .overlay(content: {
                    Image(image)
                })
                .background(.white.opacity(0.2))
                .cornerRadius(20)
        }
    }
}

/* Eine View die ein Gitter auf ein ZStack legt,
   sie dienen als Hilfslinien für die UI-Platzierung. */
struct GridHelper: View {
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            
            Path { path in
                for x in stride(from: 0, to: width, by: 20) {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                }
                for y in stride(from: 0, to: height, by: 20) {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                }
            }
            .stroke(Color.red.opacity(0.2), lineWidth: 1)
        }
    }
}

#Preview {
    OnBoardingScreen()
}
