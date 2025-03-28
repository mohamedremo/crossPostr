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
            AppTheme.cardGradient.ignoresSafeArea()
            HStack {
                VStack {
                    VStack {
                        Image("AppLogoPng")
                            .resizable()
                            .frame(width: 100, height: 100)
                    }
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
        .frame(maxHeight: 120)
    }
}
