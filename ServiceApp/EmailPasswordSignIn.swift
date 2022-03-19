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


 
//struct EPSignInView: View {
//    @StateObject var viewModel = AuthViewModel()
//
//    var body: some View {
//        Button(action: {
//            viewModel.createUser(email: "a@aol.com", password: "password")
//        }) {
//            Text("Sign In").foregroundColor(.red)
//        }
//    }
//}


//class EPAuthViewModel: ObservableObject {

//    @Published var state: AuthViewModel.SignInState = .signedOut
//
//    func signIn(email: String, password: String) {
//        authenticateUser(for: email, password: password)
//    }
//
//    func signOut() {
//        GIDSignIn.sharedInstance.signOut()
//        do {
//            try Auth.auth().signOut()
//            self.state = .signedOut
//        } catch {
//            print(error.localizedDescription)
//        }
//    }
//
//    private func authenticateUser(for email: String, password: String) {
//        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
//            if let error = error as NSError? {
//                switch AuthErrorCode(rawValue: error.code) {
//                case .operationNotAllowed:
//                    break
//                case .userDisabled:
//                    break
//                case .wrongPassword:
//                    self?.state = .error
//                case .invalidEmail:
//                    self?.state = .error
//                default:
//                    print("Error: \(error.localizedDescription)")
//                }
//            } else {
//                let userInfo = Auth.auth().currentUser!
//                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: userInfo.uid) { exists in
//                    if exists == true {
//                        print("Welcome back \(userInfo.displayName ?? "no name")")
//                        print("User signs in successfully")
//                        print(userInfo.email, userInfo.uid)
//                        self?.state = .signedIn
//                    } else {
//                        self?.state = .error
//                        fatalError()
//                    }
//                }
//            }
//        }
//    }
//
//    func createUser(email: String, password: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
//            if let error = error as NSError? {
//                switch AuthErrorCode(rawValue: error.code) {
////                  TODO:  use combine to check email validation, if user doesn't exist, create new user, if exists,
//                case .operationNotAllowed:
//                    print("The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
//                case .emailAlreadyInUse:
//                     print("The email address is already in use by another account.")
//                   case .invalidEmail:
//                     print("The email address is badly formatted.")
//                   case .weakPassword:
//                     print("The password must be 6 characters long or more.")
//                   default:
//                       print("Error: \(error.localizedDescription)")
//                }
//            } else {
//                print("User signed up successfully")
//                self.state = .signedIn
//                let newUserInfo = Auth.auth().currentUser
//                let email = newUserInfo?.email
//                let uid = newUserInfo?.uid
//                print(email, uid)
//            }
//        }
//    }
//}
