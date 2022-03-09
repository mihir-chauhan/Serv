//
//  EmailPasswordSignIn.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 3/9/22.
//

import SwiftUI
import Firebase
import GoogleSignIn
import SDWebImageSwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices


struct EPAuthViewManager: View {
    @EnvironmentObject var viewModel: EPAuthViewModel
    var body: some View {
//        switch viewModel.state {
//        case .signedIn: SignedInView()
//        case .signedOut: SignInView()
//        }
        EPSignInView()
    }
}
 
struct EPSignInView: View {
    @EnvironmentObject var viewModel: EPAuthViewModel

    var body: some View {
        
        Button(action: {
            viewModel.signIn(email: "a@aol.com", password: "password")
        }) {
            Text("Sign In").foregroundColor(.red)
        }
    }
}


class EPAuthViewModel: ObservableObject {
    
    enum SignInState {
        case signedIn
        case signedOut
    }
//    make sign in/sign out state an environment object
    @Published var state: SignInState = .signedOut
    @Published var currentNonce: String?
    /* Google Sign In */

    func signIn(email: String, password: String) {
        authenticateUser(for: email, password: password)
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            self.state = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(for email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
          guard let strongSelf = self else { return }
          
        }

    }
}
