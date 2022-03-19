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
    
    enum SignInState: Int {
        case signedIn
        case signedOut
        case error
    }
    
    @Published var state: SignInState = .signedOut
    @Published var loading: Bool = false
    @Published var userInfoFromAuth: UserInfoFromAuth?
//    @Published var uidStoredInfo: String = ContentView().uidStoredInfo
    @State var currentNonce: String?
    /* Google Sign In */

    public func gAuthSignIn() {
        if GIDSignIn.sharedInstance.hasPreviousSignIn() {
            GIDSignIn.sharedInstance.restorePreviousSignIn { [self] user, err in
                authenticateUser(for: user, with: err)
            }
        } else {
            guard let clientID = FirebaseApp.app()?.options.clientID else { return }
            self.loading = true
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
    public func emailPwdSignIn(email: String, password: String) {
        authenticateUserEmail(for: email, password: password)
    }
    public func signOut() {
        GIDSignIn.sharedInstance.signOut()
        do {
            try Auth.auth().signOut()
            // calling ContentView because "self.state = .signedOut" is not working
            ContentView().signInState = .signedOut
        } catch {
            print(error.localizedDescription)
        }
    }

    private func authenticateUser(for user: GIDGoogleUser?, with err: Error?) {
        if let err = err {
            print(err.localizedDescription)
            self.loading = false
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
                self.loading = false
                self.state = .error
            } else {
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.user.uid) { exists in
                    self.loading = false
                    if exists == true {
                        print("Welcome back \(user!.user.displayName ?? "no name")")
                        self.state = .signedIn
                    }
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(uid: user!.user.uid)
                        print("Tell us about yourself")
                    }
                }
                let user = user?.user
//                self.userInfoFromAuth = UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email)
                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
//                self.uidStoredInfo = user!.uid
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
                let user = Auth.auth().currentUser
//                self.userInfoFromAuth = UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email)
                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
//                self.uidStoredInfo = user!.uid
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
                    self.state = .error
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
    
    
    /* Email & Password */
    private func authenticateUserEmail(for email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.loading = true
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .operationNotAllowed:
                    break
                case .userDisabled:
                    break
                case .wrongPassword:
                    self?.state = .error
                case .invalidEmail:
                    self?.state = .error
                default:
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                let userInfo = Auth.auth().currentUser!
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: userInfo.uid) { exists in
//                    if exists == true {
                        self?.loading = false
                        print("Welcome back \(userInfo.displayName ?? "no name")")
                        print("User signs in successfully")
                        print(userInfo.email!, userInfo.uid)
                        self?.state = .signedIn
//                    } else {
//                        self?.state = .error
//                        #warning("the uid matches up with one in database, but it says that it can't find the user in db")
//                        fatalError("\(userInfo.uid)")
//                    }
                }
            }
        }
    }
    
    func createUser(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.loading = true
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
//                  TODO:  use combine to check email validation, if user doesn't exist, create new user, if exists,
                case .operationNotAllowed:
                    print("The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
                case .emailAlreadyInUse:
                     print("The email address is already in use by another account.")
                   case .invalidEmail:
                     print("The email address is badly formatted.")
                   case .weakPassword:
                     print("The password must be 6 characters long or more.")
                   default:
                       print("Error: \(error.localizedDescription)")
                }
            } else {
                print("User signed up successfully")
                self.state = .signedIn
                self.loading = false
                let user = Auth.auth().currentUser
                
//                self.userInfoFromAuth = UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email)
                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
//                self.uidStoredInfo = user!.uid
            }
        }
    }
    
    private func encodeUserInfo(for value: UserInfoFromAuth) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: "userInfo")
        } catch {
            print("cannot encode")
        }
    }
    
    func decodeUserInfo() -> UserInfoFromAuth? {
        if let data = UserDefaults.standard.data(forKey: "userInfo") {
            do {
                let decoder = JSONDecoder()
                let data = try decoder.decode(UserInfoFromAuth.self, from: data)
                return data

            } catch {
                print("Unable to decode")
            }
        }
        return nil
    }
}

struct UserInfoFromAuth: Codable {
    var uid: String?
    
    var displayName: String?
    var photoURL: URL?
    var email: String?
}
