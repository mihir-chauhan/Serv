//
//  FirestoreCRUD.swift
//  ServiceApp
//
//  Created by mimi on 1/5/22.
//

import SwiftUI
import FirebaseFirestore
import MapKit

class FirestoreCRUD: ObservableObject {
    let db = Firestore.firestore()
    
    func getAllEvents() {
        db.collection("Environment")
            .addSnapshotListener { (snap, err) in
                if let error = err {
                    print(error.localizedDescription)
                    return
                } else {
                    for i in snap!.documentChanges {
                        let name = i.document.get("time") as? Date ?? Date()
                        let location = i.document.get("location") as? GeoPoint
                        print(name, location?.latitude as Any, location?.longitude as Any)
                    }
                }
            }
    }
    
    func AddToAttendeesList(eventID: String) {
        db.collection("")
    }
}
