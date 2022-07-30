//
//  TabBarController.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/29/22.
//

import Foundation

final class TabBarController: ObservableObject {
    @Published var selectedIndex: TabBarItem = .home
}
