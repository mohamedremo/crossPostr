//
//  TabBarViewModel.swift
//  crosspostr
//
//  Created by Mohamed Remo on 18.03.25.
//
import Foundation

class TabBarViewModel: ObservableObject {
    @Published var selectedPage: TabBarPage = .home
}
