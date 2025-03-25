//
//  TopBarView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 25.03.25.
//
import SwiftUI

struct TopBarView: View {
    @ObservedObject var vM: TabBarViewModel
    
    var body: some View {
        ZStack {
            AppTheme.cardGradient.ignoresSafeArea(edges: .top)
                .frame(maxHeight: 150)
                .presentationCornerRadius(30)
                .background(ignoresSafeAreaEdges: .top)

            HStack {
                VStack {
                    VStack {
                        Image("AppLogoPng")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
                    .padding()
                }

                VStack(alignment: .leading) {
                    Text(vM.profile?.fullName ?? "No Profile")
                        .font(.title)
                        .fontWeight(.light)
                        .foregroundStyle(.white)
                    Text(vM.profile?.email ?? "No Email")
                        .font(.callout)
                        .fontWeight(.ultraLight)
                        .foregroundStyle(.white.opacity(0.6))
                }
                Spacer()
            }
        }
    }
}
