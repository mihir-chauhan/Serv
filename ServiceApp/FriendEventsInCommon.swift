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
            if friendsArray != nil {
                for friend in friendsArray! {

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
}
