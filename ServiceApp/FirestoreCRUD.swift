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
    
    var allCategories: [String] = ["Environmental", "Humanitarian", "Other"]
    @Published var allFIRResults = [EventInformationModel]()
//
//    init() {
//        //getAllEvents()
//    }
//
//    func getAllEvents() {
//        for i in allCategories {
//            db.collection("EventTypes/\(i)/Events")
//                .addSnapshotListener { (snap, err) in
//                    if let error = err {
//                        print(error.localizedDescription)
//                        return
//                    } else {
//                        for j in snap!.documentChanges {
//                            let id = j.document.documentID
//                            let host = j.document.get("host") as? String ?? "Host unavailable"
//                            let ein = j.document.get("ein") as? String ?? "No valid ein"
//                            let name = j.document.get("name") as? String ?? "no name"
//                            let description = j.document.get("description") as? String ?? "No description!"
//                            _ = j.document.get("attendees") as? [String] ?? [String]()
//                            let time = j.document.get("time") as? Timestamp
//                            let imageURL = j.document.get("images") as? [String] ?? [String]()
//                            let location = j.document.get("location") as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
//
//                            self.allFIRResults.append(EventInformationModel(
//                                FIRDocID: id,
//                                name: name,
//                                host: host,
//                                ein: ein,
//                                category: i,
//                                time: time?.dateValue() ?? Date(),
//                                images: imageURL,
//                                coordinate: CLLocationCoordinate2D(latitude: (location.latitude), longitude: (location.longitude)),
//                                description: description
//
//                            ))
//                        }
//                    }
//                }
//        }
//    }
    
    func AddToAttendeesList(eventID: String, eventCategory: String) {
        var mapValues: [String : Any] {
            return [ user_uuid! :
                        [
                            "name" : AuthViewModel().decodeUserInfo()?.displayName! as Any,
                            "checkInTime" : "",
                            "checkOutTime" : "",
                        ]
            ]
        }
            
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID).updateData(["attendees" : mapValues])
    }
    
    func checkForMaxSlot(eventID: String, eventCategory: String
//                         completion: @escaping (_ maxSlotReached: Bool) -> ()
    ) {
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID)
            .getDocument { doc, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                let data = doc?.data()
                let maxSlots = data?["maxSlots"] as? Int
                let attendeeCount = data?["attendees"]
                print("slots", maxSlots, attendeeCount)
//                completion(true)
            }
        
    }
    
    func addCheckInTime(eventID: String, eventCategory: String, checkInTime: Date? = nil) {
        var mapValues: [String : Any] {
            return [ user_uuid! :
                [
                    "name" : AuthViewModel().decodeUserInfo()?.displayName! as Any,
                    "checkInTime" : checkInTime!,
                    "checkOutTime" : "",
                ]
            ]
        }
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID).updateData(
                ["attendees" : mapValues]
            )
    }
    
    func serviceCompletedPerWeek(start: Date, end: Date, completion: @escaping (_ hours: Double?) -> ()) {
        var totalHours: Double = 0
        db.collection("Volunteer Accounts").document("OsRBPZO2ScYik6P8By7YbxXLmwU2").collection("Attended Event Data")
            .whereField("checkOutTime", isGreaterThan: start)
            .whereField("checkOutTime", isLessThan: end)
        
            .getDocuments { doc, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
//                print(doc?.count)
                for i in doc!.documents {
                    print(i.documentID)
                    let checkOutTime = i.get("hoursSpent") as? Double
                    
                    totalHours += checkOutTime!
                }
                completion(totalHours)
            }
    }
    
    
    func RemoveFromAttendeesList(eventID: String, eventCategory: String, user_uuid: String) {
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID)
            .updateData(["attendees.\(user_uuid)" : nil])
        
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
    
    func getSpecificEvent(eventID: String, completion: @escaping (_ data: EventInformationModel) -> ()) {
        let categories = ["Educational", "Environmental", "Humanitarian"]
        for i in categories {
            db.collection("EventTypes/\(i)/Events").document(eventID)
                .getDocument { snap, err in
                    
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    if snap!.exists {
                        let id = snap!.documentID
                        let host = snap!.get("host") as? String ?? "Host unavailable"
                        let ein = snap!.get("ein") as? String ?? "No valid ein"
                        let name = snap!.get("name") as? String ?? "no name"
                        _ = snap!.get("attendees") as? [String] ?? [String]()
                        let time = snap!.get("time") as? Timestamp
                        let imageURL = snap!.get("images") as? [String] ?? [String]()
                        let location = snap!.get("location") as? GeoPoint
                        
                        completion(
                            EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                ein: ein,
                                category: i,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!)
                                
                            )
                            )
                    }
                }
        }
    }
    
    func sortGivenDateRange(startEventDate: Date, endEventDate: Date) {
        db.collection("EventTypes").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    self.db.collection("EventTypes/\(document.documentID)/Events")
                        .whereField("time", isGreaterThan: startEventDate)
                        .whereField("time", isLessThan: endEventDate)
                        .getDocuments { snapshot, err in
                            if let err = err {
                                print(err.localizedDescription)
                            } else {
                                for i in snapshot!.documents {
                                    print(i.documentID)
                                }
                            }
                        }
                }
            }
        }
    }
}
