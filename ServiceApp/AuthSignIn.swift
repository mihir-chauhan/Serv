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
    static let shared = AuthViewModel()
    enum SignInState: Int {
        case signedIn
        case signedOut
        case verificationPending
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
                var bio: String = "No Bio"
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
                    user_uuid = user?.uid
                    if exists == true {
                        print("Welcome back \(user?.displayName ?? "no name"), aka: \(String(describing: user?.uid))")
                        self.state = .signedIn
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value.bio ?? "no bio?!"
                            self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: value.photoURL, email: user?.email, bio: bio))
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
    func transitionFromAppleViewController(result: AuthDataResult?) {
        let user = result?.user
        
        var bio: String = "No Bio"
        
        FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
            user_uuid = user?.uid
            print("UUID: \(user?.uid) and \(user) and \(user?.displayName)")
            if exists == true {
                
                FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                    bio = value.bio ?? "no bio?!"
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
//    public func appleOnRequest(request: ASAuthorizationAppleIDRequest) {
//        let nonce = randomNonceString()
//        currentNonce = nonce
//        let appleIDProvider = ASAuthorizationAppleIDProvider()
//        let request = appleIDProvider.createRequest()
//        request.requestedScopes = [.fullName, .email]
//        request.nonce = sha256(nonce)
//
//        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
//        authorizationController.performRequests()
//    }
//
//    public func appleOnCompletion(result: Result<ASAuthorization, Error>) {
//        print("12222111akdjflkajsflkjsdfljasdklfjnsdakjfnasdfj \(result)")
//        switch result {
//        case .success(let authResults):
//            switch authResults.credential {
//            case let appleIDCredential as ASAuthorizationAppleIDCredential:
//
//                guard let nonce = currentNonce else {
//                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
//                }
//                guard let appleIDToken = appleIDCredential.identityToken else {
//                    fatalError("Invalid state: A login callback was received, but no login request was sent.")
//                }
//                guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
//                    print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
//                    return
//                }
//
//                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce, accessToken: nil)
//                Auth.auth().signIn(with: credential) { (authResult, error) in
//                    print("1111akdjflkajsflkjsdfljasdklfjnsdakjfnasdfj")
//                    if (error != nil) {
//                        // Error. If error.code == .MissingOrInvalidNonce, make sure
//                        // you're sending the SHA256-hashed nonce as a hex string with
//                        // your request to Apple.
//                        print(error?.localizedDescription as Any)
//                        self.state = .error
//                        return
//                    } else {
//                        print("lakdjflkajsflkjsdfljasdklfjnsdakjfnasdfj")
////                        let user = Auth.auth().currentUser
//                        let user = authResult?.user
//
//                        var bio: String = "No Bio"
//
//                        FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
//                            user_uuid = user?.uid
//                            if exists == true {
//
//                                FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
//                                    bio = value.bio ?? "no bio?!"
//                                    self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email, bio: bio))
//                                }
//                            } else {
//                                FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(
//                                    uid: user?.uid,
//                                    displayName: user?.displayName,
//                                    photoURL: user?.photoURL,
//                                    email: user?.email
//                                ))
//                                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email))
//                            }
//
//                            UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
//
//                            self.state = .signedIn
//                            self.loading = false
//                        }
//
//                        print("signed in through Apple")
//                        self.state = .signedIn
//                    }
//
//
//                }
//            default:
//                break
//
//            }
//        default:
//            break
//        }
//    }
//
//    @available(iOS 13, *)
//    func sha256(_ input: String) -> String {
//        let inputData = Data(input.utf8)
//        let hashedData = SHA256.hash(data: inputData)
//        let hashString = hashedData.compactMap {
//            return String(format: "%02x", $0)
//        }.joined()
//
//        return hashString
//    }
//
//    private func randomNonceString(length: Int = 32) -> String {
//        precondition(length > 0)
//        let charset: Array<Character> =
//        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
//        var result = ""
//        var remainingLength = length
//
//        while remainingLength > 0 {
//            let randoms: [UInt8] = (0 ..< 16).map { _ in
//                var random: UInt8 = 0
//                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
//                if errorCode != errSecSuccess {
//                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
//                }
//                return random
//            }
//
//            randoms.forEach { random in
//                if remainingLength == 0 {
//                    return
//                }
//
//                if random < charset.count {
//                    result.append(charset[Int(random)])
//                    remainingLength -= 1
//                }
//            }
//        }
//        return result
//    }

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
                    user_uuid = user.uid
                    if(exists) {
                        var bio: String = "No Bio"
                        self?.loading = false
                        print("Welcome back \(user.displayName ?? "no name")")
                        print("User signs in successfully")
                        print(user.email!, user.uid)
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value.bio ?? "No bio?"
                            
                            print(user.displayName)
                            
                            self?.encodeUserInfo(for: UserInfoFromAuth(uid: user.uid, displayName: value.displayName, photoURL: value.photoURL, email: user.email, bio: bio))
                        }
                        self?.state = .signedIn
                        
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
                var bio: String = "No Bio"
                user_uuid = user!.uid
                print("kjadsjlfndafkjndfjnhere 11111111121212121 \(user!.uid)")
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { [self] exists in
                    print("kjadsjlfndafkjndfjnhere 11111111121212121 \(exists)")
//                  THIS WILL PROBABLY NEVER BE REACHED
                    if exists {
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value.bio ?? "no bio?!"
                            print(bio)
                            self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, bio: bio))
                        }
                        
                        self.state = .signedIn
                    }
                    
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email))
                        encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email))
                        
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
                            self.state = .verificationPending
                            
                            
                        }
                        
                    }
                    UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                    
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
            }
        }
    }
    
    func encodeUserInfo(for value: UserInfoFromAuth) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            UserDefaults.standard.set(data, forKey: "userInfo")
            
            
            print("ENTERED FUNCTION", value.photoURL)
            let imageData = try! Data(contentsOf: (value.photoURL ?? URL(string: "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg"))!)
            let image = UIImage(data: imageData)
            print("saved image", image)
            self.saveJpg(image!)
//            let imageURL = value.photoURL
//            let session = URLSession(configuration: .default)
//            session.dataTask(with: (imageURL ?? URL(string: "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg"))!) { (data, response, error) in
//                // The download has finished.
//                if let e = error {
//                    print("Error downloading cat picture: \(e)")
//                } else {
//                    if let res = response as? HTTPURLResponse {
//                        print("Downloaded cat picture with response code \(res.statusCode)")
//                        if let imageData = data {
//                            // Finally convert that Data into an image and do what you wish with it.
//                            let image = UIImage(data: imageData)
//                            print("saved new image:", image?.pngData())
//                            self.saveJpg(image!)
//                            // Do something with your image.
//                        } else {
//                            print("Couldn't get image: Image is nil")
//                        }
//                    } else {
//                        print("Couldn't get response code for some reason")
//                    }
//                }
//            }
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
    
    func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return path.first
    }
    func savePng(_ image: UIImage) {
        if let pngData = image.pngData(),
            let path = documentDirectoryPath()?.appendingPathComponent("examplePng.png") {
            try? pngData.write(to: path)
        }
    }
    func saveJpg(_ image: UIImage) {
        if let jpgData = image.jpegData(compressionQuality: 0.5),
            let path = documentDirectoryPath()?.appendingPathComponent("exampleJpg.jpg") {
            try? jpgData.write(to: path)
        }
    }
}
