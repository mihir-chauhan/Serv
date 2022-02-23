//
//  AuthSignIn.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/19/22.
//
import SwiftUI
import Firebase
//import GoogleSignIn
import SDWebImageSwiftUI
import CryptoKit
import FirebaseAuth
import AuthenticationServices


struct AuthViewManager: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
//        switch viewModel.state {
//        case .signedIn: SignedInView()
//        case .signedOut: SignInView()
//        }
        SignInView()
    }
}

struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var currentNonce:String?

    var body: some View {
//        Button(action: {
//            viewModel.signIn()
//        }) {
            SignInWithAppleButton(
                
                //Request
                onRequest: { request in
                    let nonce = viewModel.randomNonceString()
                    currentNonce = nonce
                    request.requestedScopes = [.fullName, .email]
                    request.nonce = viewModel.sha256(nonce)
                },
                
                //Completion
                onCompletion: { result in
                    switch result {
                    case .success(let authResults):
                        switch authResults.credential {
                        case let appleIDCredential as ASAuthorizationAppleIDCredential:
                            
                            guard let nonce = currentNonce else {
                                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let appleIDToken = appleIDCredential.identityToken else {
                                fatalError("Invalid state: A login callback was received, but no login request was sent.")
                            }
                            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                                print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                                return
                            }
                            
                            let credential = OAuthProvider.credential(withProviderID: "apple.com",idToken: idTokenString,rawNonce: nonce)
                            Auth.auth().signIn(with: credential) { (authResult, error) in
                                if (error != nil) {
                                    // Error. If error.code == .MissingOrInvalidNonce, make sure
                                    // you're sending the SHA256-hashed nonce as a hex string with
                                    // your request to Apple.
                                    print(error?.localizedDescription as Any)
                                    return
                                }
                                print("signed in")
                            }
                            
                            print("\(String(describing: Auth.auth().currentUser?.uid))")
                        default:
                            break
                            
                        }
                    default:
                        break
                    }
                    
                }
            ).frame(width: 280, height: 45, alignment: .center)
//        }
    }
}

//struct SignedInView: View {
//    @EnvironmentObject var viewModel: AuthViewModel
//    private let user1 = GIDSignIn.sharedInstance.currentUser
//    private let user = Auth.auth().currentUser
//    var body: some View {
//        Text("Signed in as \((user?.displayName ?? "") as String)")
//        Text("\(user?.uid ?? "")")
//        Button(action: {
//            viewModel.signOut()
//        }) {
//            Text("Sign out")
//        }
//        if let url = user1?.profile?.imageURL(withDimension: 200) {
//            let _ = print("55", user!.uid)
//            WebImage(url: url)
//                .cornerRadius(15)
//
//        }
//    }
//}


class AuthViewModel: ObservableObject {
    
//    enum SignInState {
//        case signedIn
//        case signedOut
//    }
//    @Published var state: SignInState = .signedOut
//
    // Google Sign In
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
//    func authenticateUser(for user: GIDGoogleUser?, with err: Error?) {
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
    
    // Apple Sign In
    
    func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
            }.joined()

            return hashString
        }
    
    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    
    
}
