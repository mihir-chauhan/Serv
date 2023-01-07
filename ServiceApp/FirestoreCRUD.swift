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
    
    @Published var allCategories = [EventCategoryModel]()
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
                            "name" : AuthViewModel.shared.decodeUserInfo()?.displayName! as Any,
                            "checkInTime" : "",
                            "checkOutTime" : "",
                        ]
            ]
        }
        
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID).updateData([
                "attendees.\(user_uuid!).name" : (AuthViewModel.shared.decodeUserInfo()?.displayName!)! as Any,
                "attendees.\(user_uuid!).checkInTime" : nil,
                "attendees.\(user_uuid!).checkOutTime" : nil
            ])
        //            .document(eventID).updateData(["attendees" : mapValues])
    }
    
    func checkForMaxSlot(eventID: String, eventCategory: String
                         ,
                         completion: @escaping (_ maxSlotReached: Bool) -> ()
    ) {
        //        var currentAttendees: Int = 0
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID)
            .getDocument { doc, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                let data = doc?.data()
                let maxSlots = data?["maxSlots"] as? Int
                let attendees = data?["attendees"] as? Dictionary<String, Any?>
                print(attendees?.count)
                
                //                for (key, valuezzz) in attendees! {
                //                    guard valuezzz != nil else {
                //                        return
                //                    }
                //                    currentAttendees += 1
                //                }
                
                if attendees?.count ?? 0 == maxSlots! {
                    completion(true)
                } else {
                    completion(false)
                }
            }
    }
    
    func addCheckInTime(eventID: String, eventCategory: String, checkInTime: Date? = nil) {
        var mapValues: [String : Any] {
            return [ user_uuid! :
                        [
                            "name" : AuthViewModel.shared.decodeUserInfo()?.displayName! as Any,
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
    
    func serviceCompletedPerWeek(for user: String, start: Date, end: Date, completion: @escaping (_ hours: Double?) -> ()) {
        var totalHours: Double = 0
        let g = DispatchGroup()
        let docRef = db.collection("Volunteer Accounts").document(user).collection("Attended Event Data")
            .whereField("checkOutTime", isGreaterThan: start)
            .whereField("checkOutTime", isLessThan: end)
        
        g.enter()
        
        docRef.getDocuments { doc, err in
            if let err = err {
                print(err.localizedDescription)
                g.leave()
                return
            }
            for i in doc!.documents {
                let checkOutTime = i.get("hoursSpent") as? Double
                
                totalHours += checkOutTime!
                print("Got data!")
                
            }
            g.leave()
            
            g.notify(queue: .main) {
                print("TOTAL HOURS: \(totalHours)")
                completion(totalHours)
            }
            
        }
    }
    
    func allTimeCompleted(for user: String, completion: @escaping (_ totalHours: [CGFloat]) -> ()) {
        var totalHours: [CGFloat] = []
        let docRef = db.collection("Volunteer Accounts").document(user).collection("Attended Event Data")
            .order(by: "checkOutTime", descending: true)
        
        docRef.getDocuments { snap, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            for i in snap!.documents {
                let hours = i.get("hoursSpent") as! Double
                totalHours.append(CGFloat(hours))
            }
            completion(totalHours)
        }
    }
    
    func RemoveFromAttendeesList(eventID: String, eventCategory: String, user_uuid: String) {
        db.collection("EventTypes/\(eventCategory)/Events")
            .document(eventID)
            .updateData(["attendees.\(user_uuid)" : FieldValue.delete()])
        
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
                let address = snap?.get("address") as? String
                let phone = snap?.get("phone") as? String
                completion(OrganizationInformationModel(name: name!, email: email!, website: website!, address: address!, phone: phone!))
            }
        
    }
    
    func queryAllCategoriesClosure(resetAllToTrue: Bool, completion: @escaping (_ data: Int) -> ())  {
        self.allCategories = [EventCategoryModel]()
        db.collection("EventTypes").getDocuments { snap, err in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(0)
            } else {
                for document in snap!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let catName = document.documentID
                    let emoji = document.get("emoji") as? String ?? "."
                    let description = document.get("details") as! String
                    
                    var temp = EventCategoryModel(name: catName, icon: emoji, description: description)
                    
                    if(resetAllToTrue) {
                        UserDefaults.standard.setValue(true, forKey: "\(catName)")
                        temp.savedCategory = true
                    } else if(UserDefaults.standard.bool(forKey: "\(catName)")) {
                        temp.savedCategory = true
                    }
                    self.allCategories.append(temp)
                }
                completion(1)
            }
        }
    }

    
    func getSpecificEvent(eventID: String, completion: @escaping (_ data: EventInformationModel) -> ()) {
        print("countcount", allCategories.count)
        for (index, category) in allCategories.enumerated() {
            db.collection("EventTypes/\(category.name)/Events").document(eventID)
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
                        let description = snap!.get("description") as? String ?? "no description"
                        
                        completion(
                            EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                ein: ein,
                                category: category.name,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location?.latitude)!, longitude: (location?.longitude)!),
                                description: description
                                
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
    
    func getEventHistory(uid: String, completion: @escaping (_ eventHistory: [EventHistoryInformationModel]) -> ()) {
        var eventHistory: [EventHistoryInformationModel] = []
        db.collection("Volunteer Accounts").document(uid).collection("Attended Event Data")
            .order(by: "checkOutTime", descending: true)
            .limit(to: 10)
            .getDocuments { doc, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                if !doc!.isEmpty {
                    for i in doc!.documents {
                        let eventName = i.get("eventName") as? String
                        let dateOfService = i.get("checkOutTime") as! Timestamp
                        let hoursSpent = i.get("hoursSpent") as! Double
                        
                        let dateFormatter = DateFormatter()
                        let date = dateOfService.dateValue()
                        dateFormatter.dateStyle = .medium
                        dateFormatter.timeStyle = .none
                        
                        eventHistory.append(EventHistoryInformationModel(eventName: eventName ?? "Unknown", dateOfService: date, hoursSpent: hoursSpent))
                    }
                    completion(eventHistory)
                }
                
            }
        
    }
    
    //    func updatePfpInFirestore(url: URL) {
    //        db.collection("Volunteer Accounts").document(user_uuid!).updateData([
    //            "UserInfo.photoURL" : url.absoluteString
    //        ])
    //
    //    }
    func queryAllCategories(resetAllToTrue: Bool)  {
        self.allCategories = [EventCategoryModel]()
        db.collection("EventTypes").getDocuments { snap, err in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in snap!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let catName = document.documentID
                    let emoji = document.get("emoji") as? String ?? "."
                    let description = document.get("details") as! String
                    
                    var temp = EventCategoryModel(name: catName, icon: emoji, description: description)
                    
                    if(resetAllToTrue) {
                        UserDefaults.standard.setValue(true, forKey: "\(catName)")
                        temp.savedCategory = true
                    } else if(UserDefaults.standard.bool(forKey: "\(catName)")) {
                        temp.savedCategory = true
                    }
                    self.allCategories.append(temp)
                }
            }
        }
    }
    
    func getBroadcast(eventID: String, eventCategory: String, completion: @escaping (_ broadcasts: [BroadCastMessageModel]?) -> ()) {
        var temp = [BroadCastMessageModel]()
        db.collection("EventTypes")
            .document(eventCategory)
            .collection("Events")
            .document(eventID)
            .collection("Broadcasts").getDocuments { snap, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                for doc in snap!.documents {
                    let msg = doc.get("message") as! String
                    let time = doc.get("timestamp") as! Timestamp
                    
                    temp.append(BroadCastMessageModel(message: msg, date: time.dateValue()))
                    print("354", temp)
                }
                completion(temp)
            }
    }
}
