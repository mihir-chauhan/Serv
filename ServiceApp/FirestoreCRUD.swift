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
    var eventInfo: [EventInformationModel] = [EventInformationModel]()
    
    func getAllEvents(_ completion: @escaping (EventInformationModel) -> Void) {
        db.collection("Environment")
            .addSnapshotListener { (snap, err)  in
                if let error = err {
                    print(error.localizedDescription)
                    return
                } else {
                    for i in snap!.documentChanges {
                        let host = i.document.get("host") as? String ?? "Host unavailable"
                        let attendees = i.document.get("attendees") as? [String] ?? [String]()
                        let name = i.document.get("time") as? Date ?? Date()
                        let location = i.document.get("location") as? GeoPoint
                        print(host, attendees, name, location?.latitude as Any, location?.longitude as Any)
                        completion(EventInformationModel(
                            id: UUID(),
                            name: "",
                            host: host,
                            category: "",
                            time: Date(),
                            coordinate: CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!),
                            description: "",
                            enterDetailView: false))
                        
                    }
                }
            }
    }
    
    func AddToAttendeesList(eventID: String) {
        db.collection("Environment")
            .document(eventID).updateData(["attendees" : FieldValue.arrayUnion([user_uuid])])
    }
    
    func fetchUpdates() {
        
    }
}
