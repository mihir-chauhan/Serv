//
//  RealtimeDatabaseCRUD.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/18/22.
//

import Foundation
import FirebaseDatabase
import FirebaseFirestore
import SwiftUI


var ref: DatabaseReference! = Database.database().reference()
//#error("refractor to firestore")
class FirebaseRealtimeDatabaseCRUD {
    let db = Firestore.firestore()
    func readFriends(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
//        ref.child("\(uuidString)/Friends").getData(completion:  { error, snapshot in
//            guard error == nil else {
//                print(error!.localizedDescription)
//                handler(nil);
//                return;
//            }
//            let friendsArray = snapshot.value as? Array<String>
//            handler(friendsArray)
//        })
        db.collection("Users")
            .document(uuidString)
            .getDocument { document, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                let friendsArray = document?.get("friends") as? Array<String>
                handler(friendsArray)
            }
            
    }

    
    func readEvents(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
//        ref.child("\(uuidString)/Events").getData(completion:  { error, snapshot in
//            guard error == nil else {
//                print(error!.localizedDescription)
//                handler(nil);
//                return;
//            }
//            let eventsArray = snapshot.value as? Array<String>
//            handler(eventsArray)
//        });
        db.collection("Users")
            .document(uuidString)
            .getDocument { document, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                let eventsArray = document?.get("events") as? Array<String>
                handler(eventsArray)
            }
    }
    
    func writeFriends(for uuidString: String, friendUUID: String) {
        readFriends(for: uuidString) { friendsArray in
            //            if friendsArray == nil {
            //                let newArray = [friendUUID]
            //                ref.child("\(uuidString)/Friends").setValue(newArray)
            self.db.collection("Users")
                .document(uuidString)
                .updateData(
                    ["friends" : FieldValue.arrayUnion([friendUUID])]
                ) { err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                }
            //            } else {
            //                var newArray = friendsArray
            //                newArray?.append(friendUUID)
            //                ref.child("\(uuidString)/Friends").setValue(newArray)
            //
//            }
        }
    }
    
    func writeEvents(for uuidString: String, eventUUID: String) {
//        readEvents(for: uuidString) { eventsArray in
//            if eventsArray == nil {
//                let newArray = [eventUUID]
//                ref.child("\(uuidString)/Events").setValue(newArray)
//            } else {
//                var newArray = eventsArray
//                newArray?.append(eventUUID)
//                ref.child("\(uuidString)/Events").setValue(newArray)
//            }
//        }
        db.collection("Users")
            .document(uuidString)
            .updateData(
                ["events" : FieldValue.arrayUnion([eventUUID])]
            ) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
    }
    
    func removeEvent(for uuidString: String, eventUUID: String) {
//        readEvents(for: uuidString) { eventsArray in
//            if eventsArray == nil {
//                return
//            } else {
//                var newArray = eventsArray
//                var indexOfRemoval = 0
//
//                while indexOfRemoval < newArray!.count {
//                    if newArray![indexOfRemoval] == uuidString {
//                        return
//                    }
//                    indexOfRemoval += 1
//                }
//                newArray?.remove(at: indexOfRemoval - 1)
//                ref.child("\(uuidString)/Events").setValue(newArray)
//            }
//        }
        db.collection("Users")
            .document(uuidString)
            .updateData(
                ["events" : FieldValue.arrayRemove([eventUUID])]
            ) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
    }
    
    func checkIfUserExists(uuidString: String, completion: @escaping (Bool) -> ()) {
//        ref.root.child("\(uuidString)").observeSingleEvent(of: .value) { (snapshot) in
//            if snapshot.exists() {
//                completion(true)
//            } else {
//            completion(false)
//            }
//        }
        db.collection("Users").document(uuidString).getDocument { document, error in
            if ((document?.exists) != nil) {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func checkIfEventExistsInUser(uuidString: String, eventToCheck: String, completion: @escaping (Bool) -> ()) {
//        let reference = Database.database().reference()
//        reference.root.child("\(uuidString)").child("Events").observeSingleEvent(of: .value, with: { (snapshot) in
//
//            if snapshot.exists() {
//                for child in snapshot.children {
//                    let child = child as? DataSnapshot
//                    if let _ = child?.key, let name = child?.value as? String {
//                        if name == eventToCheck {
//                            completion(true)
//                        }
//                    }
//                }
//            } else {
//                print("Event doesn't exist")
//                completion(false)
//            }
//
//        }, withCancel: nil)
        db.collection("Users")
            .document(uuidString)
            .getDocument { document, err in
                if let err = err {
                    return
                }
                else {
                    let eventsArray = document?.get("events") as? Array<String>
                    
                    if ((eventsArray?.contains(eventToCheck)) != nil) {
                        completion(true)
                    } else {
                        print("Event doesn't exist")
                        completion(false)
                    }
                    
                }
            }
    }
    
    func registerNewUser(for userInfo: UserInfoFromAuth) {
//        let userInfoAsDict = [
//            "uid" : userInfo.uid!,
//            "name" : userInfo.displayName ?? "No name",
//            "username" : userInfo.username ?? "No username :///",
//            "photoURL" : userInfo.photoURL?.absoluteString ?? "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg",
//            "email" : userInfo.email ?? "default@email.com",
//            "bio" : "Add an informative bio!"
//        ] as [String : Any]
//        ref.child("\(userInfo.uid!)/UserInfo").setValue(userInfoAsDict)
        
//        will be set when user creates it 
//        ref.child("\(userInfo.uid!)/Friends").setValue([])
//        ref.child("\(userInfo.uid!)/Events").setValue([])
        let docData = [
            "uid" : userInfo.uid!,
            "name" : userInfo.displayName ?? "No name",
            "username" : userInfo.username ?? "No username :///",
            "photoURL" : userInfo.photoURL?.absoluteString ?? "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg",
            "email" : userInfo.email ?? "default@email.com",
            "bio" : "Add an informative bio!",
            "events" : [],
            "friends" : []
        ] as [String : Any]
        db.collection("Users")
            .document(userInfo.uid)
            .setData(docData, merge: false) { err in
                if let err = err {
                    print(err.localizedDescription)
                }
            }
    }
    
    func getUserFriends(uid: String, completion: @escaping ([String]) -> ()) {
//        let friendsRef = ref.child("\(uid)").child("Friends")
//        var tempArray = [String]()
//        friendsRef.observeSingleEvent(of: .value) { snapshot in
//            var counter = 0
//            for child in snapshot.children {
//                let snap = child as! DataSnapshot
//                let dict = snap.value as! String
//                tempArray.append(dict)
//
//                counter += 1
//                if counter == snapshot.childrenCount {
//                    completion(tempArray)
//
//                }
//            }
//        }
    }
    
    func getUserFriendInfo(uid: String, completion: @escaping (UserInfoFromAuth) -> ()) {
        ref.child("\(uid)/UserInfo").observeSingleEvent(of: .value, with: { snap in
            let value = snap.value as? NSDictionary
            let displayName = value?["name"] as? String ?? "no name"
            let photoURL = value?["photoURL"] as? String ?? "no image"
            
            let model = UserInfoFromAuth(displayName: displayName, photoURL: URL(string: photoURL))
//            this eventually will have to return a list of elements
            print(displayName)
            completion(model)
        })
    }
    
    func getProfilePictureFromURL(uid: String, completion: @escaping (URL) -> ()) {
        ref.child("\(uid)/UserInfo").observeSingleEvent(of: .value, with: { snap in
            let value = snap.value as? NSDictionary
            let photoURL = value?["photoURL"] as? String ?? "no image"
            completion(URL(string: photoURL)!)
        })
    }
    
    func updateUserBio(uid: String, newBio: String) {
//        ref.child("\(uid)/UserInfo").updateChildValues( [ "bio" : newBio ] ) { err, ref in
//            if let err = err {
//                print(err.localizedDescription)
//            } else {
//                print("\t \(ref) saved successfully")
//            }
//        }
        db.collection("Users")
            .document(uid)
            .updateData(
                ["bio" : newBio]
            ) { err in
                if let err = err {
                    print(err.localizedDescription)
                }
            }
    }
    
    func retrieveUserBio(uid: String, completion: @escaping (String) ->()) {
//        ref.child("\(uid)/UserInfo").observeSingleEvent(of: .value, with: { snap in
//            let value = snap.value as? NSDictionary
//            let bio = value?["bio"] as? String ?? "no fucking bio fuck"
//            completion(bio)
//        })
        db.collection("Users")
            .document(uid)
            .getDocument { document, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
            }
    }
}

