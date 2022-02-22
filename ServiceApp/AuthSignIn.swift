//
//  AuthSignIn.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/19/22.
//
import SwiftUI
import Firebase
import GoogleSignIn
import SDWebImageSwiftUI

struct AuthViewManager: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        switch viewModel.state {
        case .signedIn: SignedInView()
        case .signedOut: SignInView()
        }
    }
}

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Button(action: {
            viewModel.signIn()
        }) {
            HStack {
                Image("google")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 35, height: 35)
                Text("Sign in with Google")
            }
        }
    }
}

struct SignedInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    private let user1 = GIDSignIn.sharedInstance.currentUser
    private let user = Auth.auth().currentUser
    var body: some View {
        Text("Signed in as \((user?.displayName ?? "") as String)")
        Text("\(user?.uid ?? "")")
        Button(action: {
            viewModel.signOut()
        }) {
            Text("Sign out")
        }
        if let url = user1?.profile?.imageURL(withDimension: 200) {
            let _ = print("55", user!.uid)
            WebImage(url: url)
                .cornerRadius(15)
            
        }
    }
}

class AuthViewModel: ObservableObject {
    enum SignInState {
        case signedIn
        case signedOut
    }
    @Published var state: SignInState = .signedOut
    
    func signIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [self] user, err in
                authenticateUser(for: user, with: err)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            let config = GIDConfiguration(clientID: clientID)
            
            guard
                let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let root = screen.windows.first?.rootViewController
            else { return }
            
            GIDSignIn.sharedInstance.signIn(with: config, presenting: root) { [self] user, err in
                authenticateUser(for: user, with: err)
            }
        }
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
    
    private func authenticateUser(for user: GIDGoogleUser?, with err: Error?) {
        if let err = err {
            print(err.localizedDescription)
            return
        }
        
        guard
            let auth = user?.authentication,
            let idToken = auth.idToken
        else { return }
        
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: auth.accessToken)
        
        Auth.auth().signIn(with: credential) { user, err in
            if let err = err {
                print(err.localizedDescription)
            } else {
                self.state = .signedIn
                
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.user.uid) { exists in
                    if exists == true {
                        print("Welcome back \(user!.user.displayName ?? "no name")")
                    }
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(uid: user!.user.uid)
                        print("Tell us about yourself")
                    }
                }

            }
        }
    }
}
