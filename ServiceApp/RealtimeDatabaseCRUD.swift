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
    func readFriends(from uuidString: String) { //}-> NSArray {
        ref.child("\(uuidString)/Friends").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            let friendsArray = snapshot.value as? NSArray
            let friendUUID = friendsArray?[0] as? String ?? "Unknown";
        });
    }
    
    func readEvents(for uuidString: String) {
        ref.child("\(uuidString)/Events").getData(completion:  { error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            let eventsArray = snapshot.value as? NSArray
            let eventName = eventsArray?[0] as? String ?? "Unknown";
        });
    }
}

