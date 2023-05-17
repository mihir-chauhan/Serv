//
//  AuthSignIn.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 2/19/22.
//
import SwiftUI
import Firebase
import FirebaseFirestore
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
    
    @Published var showAgeVerification = false
    @Published var inlineErrorDialog = ""
    @Published var userInfoFromAuth: UserInfoFromAuth?
    @Published var apnsToken = ""
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
        self.loading = true
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
                            bio = value.bio ?? "No Bio"
                            self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: value.photoURL, email: user?.email, bio: bio, birthYear: 0))
                        }
                        UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                        
                        self.loading = false
                        self.state = .signedIn
                    }
                    else {
                        // MARK: detecting new user
                        UserDefaults.standard.set(true, forKey: "newAppleGoogleUser")
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(
                            uid: user?.uid,
                            displayName: user?.displayName,
                            photoURL: user?.photoURL,
                            email: user?.email,
                            birthYear: 0))
                        print("Tell us about yourself")
                        
                        self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: user?.photoURL, email: user?.email, birthYear: 0))
                        
                        UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                        
                        self.loading = false
                        self.state = .signedIn
                    }
                }
            }
        }
    }
    
    /* Apple Sign In */
    func transitionFromAppleViewController(result: AuthDataResult?, name: String) {
        self.loading = true
        let user = result?.user
        
        var bio: String = "No Bio"
        
        FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { exists in
            user_uuid = user?.uid
            print("UUID: \(user?.uid) and \(user) and \(user?.displayName) and \(user?.photoURL)")
            if exists == true {
                
                FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                    bio = value.bio ?? "No Bio"
                    self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: user?.displayName, photoURL: value.photoURL, email: user?.email, bio: bio, birthYear: 0))
                    
                    UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                    
                    print("siasdfasdfgned in through Apple")
                    self.state = .signedIn
                    self.loading = false
                }
            } else {
                let changeRequest = user!.createProfileChangeRequest()
                changeRequest.displayName = name
                changeRequest.commitChanges { (error) in
                    print("Error changing name: \(error)")
                }
                UserDefaults.standard.set(true, forKey: "newAppleGoogleUser")
                FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(
                    uid: user?.uid,
                    displayName: name,
                    photoURL: user?.photoURL,
                    email: user?.email,
                    birthYear: 0
                ))
                self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, photoURL: user?.photoURL, email: user?.email, birthYear: 0))
                
                UserDefaults.standard.set(user?.uid, forKey: "user_uuid")
                
                print("siasdfasdfgned in through Apple")
                self.state = .signedIn
                self.loading = false
            }
        }
    }

    //MARK: Email & Password
    private func authenticateUserEmail(for email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            self?.loading = true
            if let error = error as NSError? {
                self?.loading = false
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
                            
                            self?.encodeUserInfo(for: UserInfoFromAuth(uid: user.uid, displayName: value.displayName, photoURL: value.photoURL, email: user.email, bio: bio, birthYear: value.birthYear))
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
    
    func createUser(name: String, username: String, email: String, password: String, birthYear: Int) {
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
                FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: user!.uid) { [self] exists in
//                  THIS WILL PROBABLY NEVER BE REACHED
                    if exists {
                        FirebaseRealtimeDatabaseCRUD().retrieveUserBio(uid: user_uuid!) { value in
                            bio = value.bio ?? "No Bio"
                            print(bio)
                            self.encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, bio: bio, birthYear: birthYear))
                        }
                        
                        self.state = .signedIn
                    }
                    
                    else {
                        FirebaseRealtimeDatabaseCRUD().registerNewUser(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, birthYear: birthYear))
                        encodeUserInfo(for: UserInfoFromAuth(uid: user?.uid, displayName: name, username: username, photoURL: user?.photoURL, email: user?.email, birthYear: birthYear))
                        
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
            }
        }
    }
    
    func deleteCurrentUser() {
        let user = Auth.auth().currentUser!
        deleteCurrentUserAndReferences(uid: user.uid, name: user.displayName!)
        user.delete { error in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("deleted user")
            }
        }
    }
    
    private func deleteCurrentUserAndReferences(uid: String, name: String) {
        let db = Firestore.firestore()
        var eventDatas = [EventInformationModel]()
//
//        // removing user from signed up events
//        for event in eventDatas {
//            FirestoreCRUD().RemoveFromAttendeesList(eventID: event.FIRDocID!, eventCategory: event.category, user_uuid: uid)
//        }
        
//        db.collectionGroup("EventTypes").whereField("attendees.\(uid).name", isGreaterThanOrEqualTo: name).getDocuments { snap, err in
//            if let err = err {
//                print(err.localizedDescription)
//            }
//            for i in snap!.documents {
//                print(i)
//            }
//        }

        // removing user from friend lists
        db.collection("Volunteer Accounts").whereField("Friends", arrayContains: uid).getDocuments { docRef, err in
            if let err = err {
                print(err.localizedDescription)
            }
            for document in docRef!.documents {
                document.reference.updateData( ["Friends" : FieldValue.arrayRemove([uid]) ] )
            }
        }
        
        // remove user from general volunteer list
        db.collection("Volunteer Accounts").document(uid).delete { err in
            if let err = err {
                print(err.localizedDescription)
            }
            print("Account deleted in firestore")
        }
        
    }
    
    //MARK: encoding information
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
    
    // MARK: profile picture cache
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
