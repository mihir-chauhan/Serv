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
    @EnvironmentObject var viewModel: AuthViewModel
    @AppStorage("signInState", store: .standard) var signInState: AuthViewModel.SignInState = .signedIn
    @State var signOutConfirmation: Bool = false
    @State var resentVerification: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                Image(systemName: "envelope.badge.fill")
                    .symbolRenderingMode(.palette)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
                    
                    
                VStack {
                    Text("Confirm your email address")
                        .font(.headline)
                        .font(.system(size: 30))
                        .bold()
                        .padding(.bottom, 5)
                    Text("We sent a confirmation email to: ")
                        .font(.headline)
                    Text(viewModel.decodeUserInfo()?.email ?? "example@ex.com")
                        .font(.headline)
                        .bold()
                        .padding(10)
                    Text("Tap Refresh after you verified your email")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.bottom, 10)
                }.padding(.horizontal)
                Button(action: {
                    let currentUser = Auth.auth().currentUser
                    currentUser?.reload { err in
                        if let err = err {
                            print(err.localizedDescription)
                            return
                        }
                        let isEmailVerified = currentUser?.isEmailVerified
                        if isEmailVerified! {
                            FirebaseRealtimeDatabaseCRUD().updateField(for: user_uuid!, fieldToUpdate: ["emailVerified" : true])
                            self.signInState = .signedIn
                            print("signed in")
                        } else {
                            print("has not verified yet")
                        }
                    }
                }) {
                    Capsule()
                        .foregroundColor(.blue)
                        .frame(width: 100, height: 35)
                        .overlay(
                            Text("Refresh")
                                .foregroundColor(.white)
                                .bold()
                        )
                }
                
                
                Button(action: {
                    let actionCodeSettings = ActionCodeSettings()
                    actionCodeSettings.url = nil
                    // The sign-in operation has to always be completed in the app.
                    actionCodeSettings.handleCodeInApp = true
                    actionCodeSettings.setIOSBundleID(Bundle.main.bundleIdentifier!)
                    
                    Auth.auth().currentUser?.sendEmailVerification { err in
                        if let err = err {
                            print(err.localizedDescription)
                            return
                        }
                        print("Email sent")
                        //                            successfully sent
                        self.signInState = .verificationPending
                        self.resentVerification = true
                    }
                }) {
                    
                    Text("Resend Verification")
                        .bold()
                }
                Text("Resent verification, check your email")
                    .font(.caption)
                    .foregroundColor(!resentVerification ? .clear : .gray)
                    .padding(.bottom, 30)
                
                Button(action: {
                    self.signOutConfirmation.toggle()
                }) {
                    Text("Sign Out")
                        .bold()
                        .foregroundColor(.red)
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
            .navigationTitle("Verification Is Pending")
        }
    }
}

struct VerificationPending_Previews: PreviewProvider {
    static var previews: some View {
        VerificationPending()
    }
}
