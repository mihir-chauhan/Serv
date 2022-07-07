//
//  RealtimeDatabaseCRUD.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/18/22.
//

import Foundation
import FirebaseDatabase
import SwiftUI


var ref: DatabaseReference! = Database.database().reference()

class FirebaseRealtimeDatabaseCRUD {
    
    func readFriends(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
        ref.child("\(uuidString)/Friends").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                handler(nil);
                return;
            }
            let friendsArray = snapshot.value as? Array<String>
            handler(friendsArray)
        })
    }

    
    func readEvents(for uuidString: String, handler: @escaping (Array<String>?) -> ()) {
        ref.child("\(uuidString)/Events").getData(completion:  { error, snapshot in
            guard error == nil else {
                print(error!.localizedDescription)
                handler(nil);
                return;
            }
            let eventsArray = snapshot.value as? Array<String>
            handler(eventsArray)
        });
    }
    
    func writeFriends(for uuidString: String, friendUUID: String) {
        readFriends(for: uuidString) { friendsArray in
            if friendsArray == nil {
                let newArray = [friendUUID]
                ref.child("\(uuidString)/Friends").setValue(newArray)
            } else {
                var newArray = friendsArray
                newArray?.append(friendUUID)
                ref.child("\(uuidString)/Friends").setValue(newArray)
                
            }
        }
    }
    
    func writeEvents(for uuidString: String, eventUUID: String) {
        readEvents(for: uuidString) { eventsArray in
            if eventsArray == nil {
                let newArray = [eventUUID]
                ref.child("\(uuidString)/Events").setValue(newArray)
            } else {
                var newArray = eventsArray
                newArray?.append(eventUUID)
                ref.child("\(uuidString)/Events").setValue(newArray)
            }
        }
    }
    
    func removeEvent(for uuidString: String, eventUUID: String) {
        readEvents(for: uuidString) { eventsArray in
            if eventsArray == nil {
                return
            } else {
                var newArray = eventsArray
                var indexOfRemoval = 0
                
                while indexOfRemoval < newArray!.count {
                    if newArray![indexOfRemoval] == uuidString {
                        return
                    }
                    indexOfRemoval += 1
                }
                newArray?.remove(at: indexOfRemoval - 1)
                ref.child("\(uuidString)/Events").setValue(newArray)
            }
        }
    }
    
    func checkIfUserExists(uuidString: String, completion: @escaping (Bool) -> ()) {
        ref.child(uuidString).observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() {
                completion(true)
            }
            completion(false)
        }
    }
    
    func checkIfEventExistsInUser(uuidString: String, eventToCheck: String, completion: @escaping (Bool) -> ()) {
        let reference = Database.database().reference()
        reference.root.child("\(uuidString)").child("Events").observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.exists() {
                for child in snapshot.children {
                    let child = child as? DataSnapshot
                    if let _ = child?.key, let name = child?.value as? String {
                        if name == eventToCheck {
                            completion(true)
                        }
                    }
                }
            } else {
                print("Event doesn't exist")
                completion(false)
            }

        }, withCancel: nil)
    }
    
    func registerNewUser(for userInfo: UserInfoFromAuth) {
        let userInfoAsDict = [
            "uid" : userInfo.uid!,
            "name" : userInfo.displayName ?? "No name",
            "username" : userInfo.username ?? "No username :///",
            "photoURL" : userInfo.photoURL?.absoluteString ?? "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg",
            "email" : userInfo.email ?? "default@email.com"
        ] as [String : Any]
        ref.child("\(userInfo.uid!)/UserInfo").setValue(userInfoAsDict)
        
//        will be set when user creates it 
        ref.child("\(userInfo.uid!)/Friends").setValue([])
        ref.child("\(userInfo.uid!)/Events").setValue([])
    }
    
    func getUserFriends(uid: String, completion: @escaping ([String]) -> ()) {
        let friendsRef = ref.child("\(uid)").child("Friends")
        var tempArray = [String]()
        friendsRef.observeSingleEvent(of: .value) { snapshot in
            var counter = 0
            for child in snapshot.children {
                let snap = child as! DataSnapshot
                let dict = snap.value as! String
                tempArray.append(dict)
                
                counter += 1
                if counter == snapshot.childrenCount {
                    completion(tempArray)
                    
                }
            }
        }
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
//            completion(URL(string: photoURL)))
            completion(URL(string: photoURL)!)
        })
        
    }
}

