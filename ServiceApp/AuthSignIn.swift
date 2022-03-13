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
import CryptoKit
import FirebaseAuth
import AuthenticationServices

class AuthViewModel: ObservableObject {
    
    enum SignInState {
        case signedIn
        case signedOut
        case error
    }
    @Published var state: SignInState = .signedOut
    @State var currentNonce: String?
    /* Google Sign In */

    public func gAuthSignIn() {
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

    public func signOut() {
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
                

                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.user.uid) { exists in
                    if exists == true {
                        print("Welcome back \(user!.user.displayName ?? "no name")")
                        self.state = .signedIn
                    }
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(uid: user!.user.uid)
                        print("Tell us about yourself")
                    }
                }
            }
        }
    }
    
    /* Apple Sign In */
    
    public func appleOnRequest(request: ASAuthorizationAppleIDRequest) {
        let nonce = self.randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = self.sha256(nonce)
        
    }
    
    public func appleOnCompletion(result: Result<ASAuthorization, Error>) {
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
                        self.state = .error
                        return
                    }
                    print("signed in")
                    self.state = .signedIn
                }
                
                print("\(String(describing: Auth.auth().currentUser?.uid))")
            default:
                break
                
            }
        default:
            break
        }
    }
    
    private func sha256(_ input: String) -> String {
            let inputData = Data(input.utf8)
            let hashedData = SHA256.hash(data: inputData)
            let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
            }.joined()

            return hashString
        }
    
    private func randomNonceString(length: Int = 32) -> String {
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

