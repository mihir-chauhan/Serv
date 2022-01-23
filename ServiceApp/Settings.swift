//
//  Settings.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/22/22.
//

import SwiftUI

struct Settings: View {
    @State var darkMode = false
    @EnvironmentObject var environmentVariables: EnvironmentVariables
    @State private var shareActivityWithFriends = true
    @State private var seeFriendActivity = true
    var body: some View {
        VStack(spacing: 20) {
            Toggle("Dark Mode", isOn: $environmentVariables.isDarkMode)
            Toggle("Share Activity with Friends", isOn: $shareActivityWithFriends)
            Toggle("See Friend Activity", isOn: $seeFriendActivity)
        }
    }
}

class EnvironmentVariables: ObservableObject {
    @Published var isDarkMode: Bool = false
}
