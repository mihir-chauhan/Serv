//
//  VerificationPending.swift
//  ServiceApp
//
//  Created by Kelvin J on 8/16/22.
//

import SwiftUI
import FirebaseAuth
import AuthenticationServices

struct VerificationPending: View {
    @AppStorage("signInState", store: .standard) var signInState: AuthViewModel.SignInState = .signedIn
    var body: some View {
        Text("Verification Is Pending")
        Button(action: {
            print("current user: ", Auth.auth().currentUser?.uid)
           let isEmailVerified = Auth.auth().currentUser?.isEmailVerified
            if isEmailVerified! {
                FirebaseRealtimeDatabaseCRUD().updateField(for: user_uuid!, fieldToUpdate: ["emailVerified" : true])
                self.signInState = .signedIn
                print("signed in")
            } else {
                print("has not verified yet")
            }
        }) {
            Text("Refresh")
        }
    }
}

struct VerificationPending_Previews: PreviewProvider {
    static var previews: some View {
        VerificationPending()
    }
}
