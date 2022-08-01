//
//  RealtimeDatabaseCRUD.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/18/22.
//

import Foundation
import FirebaseFirestore
import SwiftUI


var ref = Firestore.firestore()

class FirebaseRealtimeDatabaseCRUD {
    
    func readFriends(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
        ref.collection("Volunteer Accounts").document(uuidString).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                handler(nil);
                return;
            }
            let friendsArray = snap?.get("Friends") as? Array<String>
            handler(friendsArray)
        }
    }
    
    func checkIfFriendAlreadyAdded(for uuidString: String, friendUUID: String, handler: @escaping (Bool?) -> ()) {
        ref.collection("Volunteer Accounts").document(uuidString).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                handler(nil);
                return;
            }
            let friendsArray = snap?.get("Friends") as? Array<String>
            handler(friendsArray?.contains(friendUUID))
        }
    }

    
    func readEvents(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
        ref.collection("Volunteer Accounts").document(uuidString).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                handler(nil);
                return;
            }
            let friendsArray = snap?.get("Events") as? Array<String>
            handler(friendsArray)
        }
    }
    
    func writeFriends(for uuidString: String, friendUUID: String) {
        ref.collection("Volunteer Accounts").document(uuidString).updateData(["Friends": FieldValue.arrayUnion([friendUUID])])
    }
    
    func writeEvents(for uuidString: String, eventUUID: String) {
        ref.collection("Volunteer Accounts").document(uuidString).updateData(["Events": FieldValue.arrayUnion([eventUUID])])
    }
    
    func removeEvent(for uuidString: String, eventUUID: String) {
        ref.collection("Volunteer Accounts").document(uuidString).updateData(["Events": FieldValue.arrayRemove([eventUUID])])
    }
    
    func checkIfUserExists(uuidString: String, completion: @escaping (Bool) -> ()) {
        ref.collection("Volunteer Accounts").document(uuidString).getDocument { (document, error) in
            if document!.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfEventExistsInUser(uuidString: String, eventToCheck: String, completion: @escaping (Bool) -> ()) {
        ref.collection("Volunteer Accounts").document(uuidString).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion(false);
                return;
            }
            let friendsArray = snap?.get("Events") as? Array<String>
            completion(friendsArray?.contains(eventToCheck) ?? false)
        }
    }
    
    func registerNewUser(for userInfo: UserInfoFromAuth) {
        let userInfoAsDict = [
            "uid" : userInfo.uid!,
            "name" : userInfo.displayName ?? "No name",
            "username" : userInfo.username ?? "No username",
            "photoURL" : userInfo.photoURL?.absoluteString ?? "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg",
            "email" : userInfo.email ?? "default@email.com",
            "bio" : "Add an informative bio!"
        ] as [String : Any]
        print("ajflajdfnasdjfnalsdfnlasfnjasdf \(userInfoAsDict)")
        ref.collection("Volunteer Accounts").document(userInfo.uid!).setData(["UserInfo": userInfoAsDict])
        
//        will be set when user creates it
//        ref.child("\(userInfo.uid!)/Friends").setValue([])
//        ref.child("\(userInfo.uid!)/Events").setValue([])
    }
    
    func getUserFriends(uid: String, completion: @escaping ([String]) -> ()) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion([]);
                return;
            }
            let friendsArray = snap?.get("Friends") as? Array<String>
            completion(friendsArray ?? [])
        }
    }
    
    func getUserFriendInfo(uid: String, completion: @escaping (UserInfoFromAuth) -> ()) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion(UserInfoFromAuth(displayName: "Unknown Name", photoURL: URL(string: "no image")))
                return;
            }
            let value = snap?.get("UserInfo") as? NSDictionary
            let displayName = value?["name"] as? String ?? "no name"
            let photoURL = value?["photoURL"] as? String ?? "no image"
            let model = UserInfoFromAuth(displayName: displayName, photoURL: URL(string: photoURL))
            print(displayName)
            completion(model)
        }
    }
    
    func getProfilePictureFromURL(uid: String, completion: @escaping (URL) -> ()) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion(URL(string: "no image")!);
                return;
            }
            let value = snap?.get("UserInfo") as? NSDictionary
            let photoURL = value?["photoURL"] as? String ?? "no image"
            completion(URL(string: photoURL)!)
        }
    }
    
    func updateUserBio(uid: String, newBio: String) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                return;
            }
            var userInfo = snap?.get("UserInfo") as? [String : Any]
            userInfo?["bio"] = newBio
            ref.collection("Volunteer Accounts").document(uid).updateData(["UserInfo": userInfo])
        }
    }
    
    func retrieveUserBio(uid: String, completion: @escaping (String) ->()) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion("No Bio");
                return;
            }
            let userInfo = snap?.get("UserInfo") as? NSDictionary
            completion(userInfo?["bio"] as? String ?? "No Bio")
        }
    }
}

