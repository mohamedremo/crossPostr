//
//  ContentView.swift
//  crosspostr
//
//  Created by Mohamed Remo on 02.02.25.
//
import SwiftUI
import GoogleSignIn
import Foundation

struct ContentView: View {
    @ObservedObject var authVM: AuthViewModel = AuthViewModel()
    @ObservedObject var tabVM: TabBarViewModel = TabBarViewModel()
    
    var body: some View {
        if authVM.isLoggedIn {
            MainTabView(tabVM: tabVM, authVM: authVM)
        } else {
            OnBoardingScreen(authVM: authVM)
        }
    }
}
