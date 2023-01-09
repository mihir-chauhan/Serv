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
    
    func updateField(for uuidString: String, fieldToUpdate: [String : Any]) {
        ref.collection("Volunteer Accounts").document(uuidString).updateData(fieldToUpdate)
    }
    
    
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
            "bio" : "Add an informative bio!",
            "verifiedEmail" : false,
            "birthYear": userInfo.birthYear,
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
        var hoursSpentArray: [CGFloat] = []
        var counter = 0
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                completion(UserInfoFromAuth(displayName: "Unknown Name", photoURL: URL(string: "no image")))
                return;
            }
            let uid = snap?.documentID
            let value = snap?.get("UserInfo") as? NSDictionary
            let displayName = value?["name"] as? String ?? "no name"
            let photoURL = value?["photoURL"] as? String ?? "no image"
            let bio = value?["bio"] as? String ?? "No Bio"

            ref.collection("Volunteer Accounts").document(uid!).collection("Attended Event Data").getDocuments { snap, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                if (snap?.isEmpty ?? true) {
                    print("ENTERED AT 137")
                    let model = UserInfoFromAuth(uid: uid, displayName: displayName, photoURL: URL(string: photoURL), hoursSpent: [])
                    completion(model)
                } else {
                    for i in snap!.documents {
                        hoursSpentArray.append(i.get("hoursSpent") as! CGFloat)
                        counter += 1
                        print("154", displayName, bio)

                        if counter == snap!.documents.count {
                            print("SSS", displayName, bio, hoursSpentArray)

                            let model = UserInfoFromAuth(uid: uid, displayName: displayName, photoURL: URL(string: photoURL), bio: bio, hoursSpent: hoursSpentArray)
                            print("RAH", model.hoursSpent)
                            completion(model)
                        }
                    }
                }
            }
            
            
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
    
    
    func setBirthYear(uid: String, birthYear: Int) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
                return;
            }
            var userInfo = snap?.get("UserInfo") as? [String : Any]
            userInfo?["birthYear"] = birthYear
            ref.collection("Volunteer Accounts").document(uid).updateData(["UserInfo": userInfo])
        }
    }
    
    func retrieveUserBio(uid: String, completion: @escaping (UserInfoFromAuth) ->()) {
        ref.collection("Volunteer Accounts").document(uid).getDocument { snap, err in
            guard err == nil else {
                print(err!.localizedDescription)
//                completion("No Bio");
                return;
            }
            let userInfo = snap?.get("UserInfo") as? NSDictionary
            let bio = userInfo?["bio"] as? String ?? "No Bio"
            let name = userInfo?["name"] as? String ?? "Johnny Smithy"
            let photoURL = userInfo?["photoURL"] as? String ?? "no url"
            let birthYear = userInfo?["birthYear"] as? Int ?? 0
            completion(UserInfoFromAuth(displayName: name, photoURL: URL(string: photoURL), bio: bio, birthYear: birthYear))
        }
    }
}

