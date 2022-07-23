//
//  Settings.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/22/22.
//

import SwiftUI

struct Settings: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State var darkMode = false
    @State private var shareActivityWithFriends = true
    @State private var seeFriendActivity = true
    @State private var signOutConfirmation = false
    var body: some View {
        VStack(spacing: 20) {
//            Toggle("Share Activity with Friends", isOn: $shareActivityWithFriends)
//            Toggle("See Friend Activity", isOn: $seeFriendActivity)
            
            Button(action: {
                self.signOutConfirmation = true
            }) {
                Text("Sign Out").foregroundColor(.red)
            }
        }.alert(isPresented: $signOutConfirmation) {
            Alert(
                title: Text("Are you sure you want to sign out?"),
                primaryButton: .destructive(Text("Sign out")) {
                    viewModel.signOut()
                },
                secondaryButton: .cancel()
                )
        }
    }
}
