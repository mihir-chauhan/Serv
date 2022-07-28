//
//  AuthSignIn.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 2/19/22.
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
    @Published var signInDialogMessage: String = ""
    @Published var loading: Bool = false
    
    @Published var inlineErrorDialog = ""
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
            self.state = .signedOut
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
                let user = user?.user
                var bio: String = "no bio [105].unique"
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
                    
//                    fatalError("\(exists)")
                    if exists == true {
                        print("Welcome back \(user?.displayName ?? "no name"), aka: \(String(describing: user?.uid))")
                        user_uuid = user?.uid
                        self.state = .signedIn
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value
                            self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email, bio: bio))
                        }
                    }
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(
                            uid: user?.uid,
                            displayName: user?.displayName,
                            photoURL: user?.photoURL,
                            email: user?.email
                        ))
                        print("Tell us about yourself")
                        
                        self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
                    }
                }
                
                
                
                UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                
                self.loading = false
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
                    } else {
//                        let user = Auth.auth().currentUser
                        let user = authResult?.user
                        
                        var bio: String = "no bio [105].unique"
                        
                        FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
                            if exists == true {
                                user_uuid = user?.uid
                                
                                FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                                    bio = value
                                    self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email, bio: bio))
                                }
                            } else {
                                FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(
                                    uid: user?.uid,
                                    displayName: user?.displayName,
                                    photoURL: user?.photoURL,
                                    email: user?.email
                                ))
                                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
                            }
                            
                            UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                            
                            self.state = .signedIn
                            self.loading = false
                        }
                        
                        print("signed in through Apple")
                        self.state = .signedIn
                    }

                    
                }
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
                    self?.signInDialogMessage = "Account has been disabled"
                    break
                case .wrongPassword:
                    print("wrong password")
                    self?.signInDialogMessage = "Invalid username or password"
                    self?.state = .error
                case .invalidEmail:
                    print("wrong email")
                    self?.signInDialogMessage = "Invalid username or password"
                    self?.state = .error
                default:
                    self?.signInDialogMessage = "An unknown error occurred"
                    print("Error: \(error.localizedDescription)")
                }
            } else {
                let user = Auth.auth().currentUser!
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user.uid) { exists in
                    if(exists) {
                        var bio: String = "no bio [105].unique"
                        self?.loading = false
                        print("Welcome back \(user.displayName ?? "no name")")
                        print("User signs in successfully")
                        print(user.email!, user.uid)
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value
                            print(bio)
                        }
                        self?.state = .signedIn
                        self?.encodeUserInfo(for: UserInfoFromAuth(uid: user.uid, displayName: user.displayName, photoURL: user.photoURL, email: user.email, bio: bio))
                        UserDefaults.standard.set(user.uid, forKey: "user_uuid")
                    } else {
                        print("HOST ACCOUNT!!!")
                        // TODO: handle if host signs in as attendee
                    }
                }
            }
        }
    }
    
    func createUser(name: String, username: String, email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
            self.loading = true
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
//                  TODO:  use combine to check email validation, if user doesn't exist, create new user, if exists,
                case .operationNotAllowed:
                    self.inlineErrorDialog = "The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section."
                    print("The given sign-in provider is disabled for this Firebase project. Enable it in the Firebase console, under the sign-in method tab of the Auth section.")
                case .emailAlreadyInUse:
                    self.inlineErrorDialog = "The email address is already in use by another account."
                     print("The email address is already in use by another account.")
                   case .invalidEmail:
                    self.inlineErrorDialog = "The email address is badly formatted."
                     print("The email address is badly formatted.")
                   case .weakPassword:
//                    self.inlineErrorDialog =  "The password must be 6 characters long or more."
                     print("The password must be 6 characters long or more.")
                   default:
                    self.inlineErrorDialog = "unknown error"
                       print("Error: \(error.localizedDescription)")
                }
            } else {
                let user = Auth.auth().currentUser
                var bio: String = "no bio [105].unique"
                
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { [self] exists in
                    if exists {
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value
                            print(bio)
                        }
                        encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, bio: bio))
                        UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                    } else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email))
                        encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email))
                        
                    }
                    UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                    self.state = .signedIn
                    self.loading = false
                }
            
                    
//                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
//                changeRequest?.displayName = name
//
//                changeRequest?.commitChanges { error in
//                    if error == nil {
//                        // Do something
//                    } else {
//                        // Do something
//                    }
//                }
                
                
                #warning("so it seems like the first time you sign in, it'll load the default of John Smith and nil values for displayName, user email, etc. But everything is normal when you sign out and sign back in. So when the user first creates the account, it goes back to the default values, and realtime db saves the default values (of lines 311-314")
//                self.state = .signedIn
//                self.loading = false
//
//                var bio: String = "no bio [105].unique"
//                FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
//                    bio = value
//                    print(bio)
//                }
                #warning("doesn't enter in submitted username yet")
//                FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email))

//                var bio: String = "Add an informative bio!"
//                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, bio: bio))
//                UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
            }
        }
    }
    
    func encodeUserInfo(for value: UserInfoFromAuth) {
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
