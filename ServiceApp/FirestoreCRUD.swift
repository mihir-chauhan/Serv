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
    
    var allCategories: [String] = ["Environment", "Humanitarian"]
    @Published var allFIRResults = [EventInformationModel]()
    
    init() {
        getAllEvents()
    }
    
    func getAllEvents() {
        for i in allCategories {
            db.collection("\(i)")
                .addSnapshotListener { (snap, err) in
                    if let error = err {
                        print(error.localizedDescription)
                        return
                    } else {
                        for j in snap!.documentChanges {
                            let id = j.document.documentID
                            let host = j.document.get("host") as? String ?? "Host unavailable"
                            let name = j.document.get("name") as? String ?? "no name"
                            _ = j.document.get("attendees") as? [String] ?? [String]()
                            let time = j.document.get("time") as? Timestamp
                            let imageURL = j.document.get("images") as? [String] ?? [String]()
                            let location = j.document.get("location") as? GeoPoint
                            
                            self.allFIRResults.append(EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                category: i,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                                
                            ))
                            print("asfnadlfanlfanldfnalsdj: ", self.allFIRResults.count, self.allFIRResults)
                        }
                    }
                }
        }
    }
    
    func AddToAttendeesList(eventID: String) {
        db.collection("Environment")
            .document(eventID).updateData(["attendees" : FieldValue.arrayUnion([user_uuid])])
    }
    
    func RemoveFromAttendeesList(eventID: String, user_uuid: String) {
        db.collection("Environment")
            .document(eventID).updateData(["attendees" : FieldValue.arrayRemove([user_uuid])])
    }
    
    func fetchUpdates() {
        
    }
}
