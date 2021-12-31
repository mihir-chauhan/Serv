//
//  BottomTabBar.swift
//  ServiceApp
//
//  Created by mimi on 12/25/21.
//

import SwiftUI

enum TabBarItem: Int, CaseIterable {
    case home = 0
    case schedule
    case plus
    case socials
    case account
    
    var icon: String {
        switch self {
            case .home: return "house"
            case .schedule: return "calendar"
            case .plus: return "plus"
            case .socials: return "globe"
            case .account: return "person"
        
        }
    }
    
    var title: String {
        switch self {
            case .home: return "Home"
            case .schedule: return "Schedule"
            case .plus: return "Discover"
            case .socials: return "Social"
            case .account: return "Account"
        }
    }
}
