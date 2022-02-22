//
//  RealtimeDatabaseCRUD.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/18/22.
//

import Foundation
import FirebaseDatabase


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
        });
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
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.hasChild(uuidString) {
                completion(true)
            }
            completion(false)
        }
    }
    
    func registerNewUser(uid: String) {
        ref.child("\(uid)/Friends").setValue(["F1"])
        ref.child("\(uid)/Events").setValue(["E1"])
        
        //TODO: Have users enter basic information about themselves via a form if they're new.
    }
}

