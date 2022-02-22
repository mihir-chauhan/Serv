////
////  AuthManager.swift
////  ServiceApp
////
////  Created by Mihir Chauhan on 2/22/22.
////
//
//import Firebase
//import GoogleSignIn
//import CryptoKit
//import FirebaseAuth
//import AuthenticationServices
//
//class AuthManager: ObservableObject {
//
//    enum SignInState {
//        case signedIn
//        case signedOut
//    }
//    @Published var state: SignInState = .signedOut
//
//    // Google Sign In
//
//    func signIn() {
//        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
//            GIDSignIn.sharedInstance.restorePreviousSignIn { [self] user, err in
//                authenticateUser(for: user, with: err)
//            }
//        } else {
//            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
//            let config = GIDConfiguration(clientID: clientID)
//
//            guard
//                let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                let root = screen.windows.first?.rootViewController
//            else { return }
//
//            GIDSignIn.sharedInstance.signIn(with: config, presenting: root) { [self] user, err in
//                authenticateUser(for: user, with: err)
//            }
//        }
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
//    private func authenticateUser(for user: GIDGoogleUser?, with err: Error?) {
//        if let err = err {
//            print(err.localizedDescription)
//            return
//        }
//
//        guard
//            let auth = user?.authentication,
//            let idToken = auth.idToken
//        else { return }
//
//        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: auth.accessToken)
//
//        Auth.auth().signIn(with: credential) { user, err in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//                self.state = .signedIn
//
//                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.user.uid) { exists in
//                    if exists == true {
//                        print("Welcome back \(user!.user.displayName ?? "no name")")
//                    }
//                    else {
//                        FirebaseRealtimeDatabaseCRUD().registerNewUser(uid: user!.user.uid)
//                        print("Tell us about yourself")
//                    }
//                }
//
//            }
//        }
//    }
//
//    // Apple Sign In
//
//    private func randomNonceString(length: Int = 32) -> String {
//      precondition(length > 0)
//      let charset: Array<Character> =
//          Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//      var result = ""
//      var remainingLength = length
//
//      while remainingLength > 0 {
//        let randoms: [UInt8] = (0 ..< 16).map { _ in
//          var random: UInt8 = 0
//          let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//          if errorCode != errSecSuccess {
//            fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//          }
//          return random
//        }
//
//        randoms.forEach { random in
//          if remainingLength == 0 {
//            return
//          }
//
//          if random < charset.count {
//            result.append(charset[Int(random)])
//            remainingLength -= 1
//          }
//        }
//      }
//
//      return result
//    }
//
//
//
//}
