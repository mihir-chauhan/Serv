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
            #warning("uncommenting code below causes an error")
//            friendsArray?.append(friendUUID)
            ref.child("\(uuidString)/Friends").setValue(friendsArray)
        }
    }
}

