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
    
    var allCategories: [String] = ["Environmental", "Humanitarian", "Educational"]
    @Published var allFIRResults = [EventInformationModel]()
    
    init() {
        getAllEvents()
    }
    
    func getAllEvents() {
        for i in allCategories {
            db.collection("EventTypes/\(i)/Events")
                .addSnapshotListener { (snap, err) in
                    if let error = err {
                        print(error.localizedDescription)
                        return
                    } else {
                        for j in snap!.documentChanges {
                            let id = j.document.documentID
                            let host = j.document.get("host") as? String ?? "Host unavailable"
                            let ein = j.document.get("ein") as? String ?? "No valid ein"
                            let name = j.document.get("name") as? String ?? "no name"
                            _ = j.document.get("attendees") as? [String] ?? [String]()
                            let time = j.document.get("time") as? Timestamp
                            let imageURL = j.document.get("images") as? [String] ?? [String]()
                            let location = j.document.get("location") as? GeoPoint
                            
                            self.allFIRResults.append(EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                ein: ein,
                                category: i,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                                
                            ))
                        }
                    }
                }
        }
    }
    
    func AddToAttendeesList(eventID: String) {
        db.collection("EventTypes/Environmental/Events")
            .document(eventID).updateData(["attendees" : FieldValue.arrayUnion([user_uuid as? String])])
    }
    
    func RemoveFromAttendeesList(eventID: String, user_uuid: String) {
        db.collection("EventTypes/Environmental/Events")
            .document(eventID).updateData(["attendees" : FieldValue.arrayRemove([user_uuid])])
    }
    
    func fetchUpdates() {
        
    }
    
    func validateOneTimeCode(data: EventInformationModel, inputtedValue: Int, completion: @escaping (_ dbCode: Bool?) -> ())  {
        db.collection("EventTypes/\(data.category)/Events")
            .document(data.FIRDocID!).getDocument() { snap, error in
                guard error == nil else {
                    return
                }
                let _dbCode = snap?.get("checkInCode") as? Int ?? -1
                
                if (_dbCode == inputtedValue) {
                    print("ENTERED")
                    completion(true)
                } else {
                    completion(false)
                }
                
            }
    }
    
    func getOrganizationDetail(ein: String, completion: @escaping (_ organizationInformationModel: OrganizationInformationModel?) -> ()) {
        var _: OrganizationInformationModel?
        db.collection("Organization Data")
            .document(ein)
            .getDocument() { snap, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                let name = snap?.get("name") as? String
                let email = snap?.get("email") as? String
                let website = snap?.get("website") as? String
                completion(OrganizationInformationModel(name: name!, email: email!, website: website!))
//                model = OrganizationInformationModel(name: name!, email: email!, website: website!)
            }
        
//        return model ?? OrganizationInformationModel(name: "No name", email: "No email", website: "no website")
    }
    
    func getSpecificEvent(eventID: [String]) {
        let categories = ["Educational", "Environmental", "Humanitarian"]
        for i in categories {
            for j in eventID {
            db.collection("EventTypes/\(i)/Events").document(j)
                .addSnapshotListener { (snap, err) in
                    
                }
            }
        }
    }
    
}
