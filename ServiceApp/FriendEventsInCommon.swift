//
//  FriendEventsInCommon.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/6/22.
//

import Foundation
import FirebaseDatabase

class FriendEventsInCommon {
    func test(handler: @escaping ([String : Array<String>?]) -> ()) {
        FirebaseRealtimeDatabaseCRUD().readFriends(for: user_uuid!) { friendsArray in
            for friend in friendsArray! {
                
//                ref.child("\(i)/Events").getData(completion:  { error, snapshot in
//                    guard error == nil else {
//                        print(error!.localizedDescription)
////                        handler(nil);
//                        return;
//                    }
//                    let eventsArray = snapshot.value as? Array<String>
//                    print("IT'S HERE", i, eventsArray)
////                    handler(eventsArray)
                ///
                FirebaseRealtimeDatabaseCRUD().readEvents(for: friend) { friendEvents in
                    if let friendEvents = friendEvents {
                        print("IT'S HERE",
                              "Events \(friend) is going: ", friendEvents)
                        handler([friend : friendEvents])
                    }
                }
            }
            
        }
    }
}
