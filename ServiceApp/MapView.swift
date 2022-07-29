//
//  MapView.swift
//  ServiceApp
//
//  Created by mimi on 12/24/21.
//

import SwiftUI
import MapKit
import CoreLocation
import GeoFireUtils
import FirebaseFirestore

struct MapView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @ObservedObject var results = FirestoreCRUD()
    @State var tracking: MapUserTrackingMode = .follow
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: viewModel.mapAnnotationsList) { pin in
                    MapAnnotation(coordinate: pin.coordinate) {
                        if pin.FIRDocID == "USER_LOCATION" {
                            ZStack {
                                Circle()
                                    .foregroundColor(.blue).opacity(0.2)
                                    //.strokeBorder(Color.blue,lineWidth: 4)
                                    //.background(Circle().foregroundColor(Color.blue).opacity(0.1))

                            }
                            .frame(width: viewModel.searchRadius * (geo.size.height/viewModel.region.span.latitudeDelta)/37.8, height: viewModel.searchRadius * (geo.size.height/viewModel.region.span.latitudeDelta)/37.8)
                            
                        } else {
                            Button(action: {
                                withAnimation(.spring()) {
                                    self.sheetObserver.sheetMode = .half
                                    self.sheetObserver.eventDetailData = pin
                                    self.viewModel.region = MKCoordinateRegion(center: pin.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                                }
                            }) {
                                ZStack {
                                    Circle()
                                        .foregroundColor(.white)
                                    Image(systemName: "mappin.circle.fill")
                                        .resizable()
                                        .foregroundColor(Color(#colorLiteral(red: 1, green: 0.2941176471, blue: 0.3098039216, alpha: 1)))
                                }.frame(width: 25, height: 25)
                                
                            }
                        }
                    }
                }
                HalfSheetModalView()
            }
            .edgesIgnoringSafeArea(.all)
            .task {
                print("APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;APPEAR;1")
                viewModel.checkIfLocationServicesIsEnabled()
            }
            .onChange(of: self.sheetObserver.eventDetailData) { newValue in
                withAnimation {
                    self.viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: newValue.coordinate.latitude - 0.02, longitude: newValue.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                }
            }
            .onDisappear {
                self.sheetObserver.sheetMode = .quarter
            }
        }
    }
}

final class LocationTrackerViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0.5, longitude: 0.5), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    @Published var queriedEventsList = [EventInformationModel]() // used as basis for filtered events since this should be untouched and copied to filtered
    
    @Published var filteredEventsList = [EventInformationModel]()
    @Published var mapAnnotationsList = [EventInformationModel]()
    @Published var searchRadius = 10.0
    
    func updateQueriedEventsList(latitude: Double, longitude: Double, radiusInMi: Double, startEventDate: Date, endEventDate: Date) {
        searchRadius = radiusInMi
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let radiusInM: Double = radiusInMi * 1609.34
        
        let queryBounds = GFUtils.queryBounds(forLocation: center,
                                              withRadius: radiusInM)
        
        let db = Firestore.firestore()
        
        db.collection("EventTypes").getDocuments() { [self] (querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                self.queriedEventsList = [EventInformationModel]()
                self.mapAnnotationsList = [EventInformationModel]()
                
                self.mapAnnotationsList.append(EventInformationModel(
                    FIRDocID: "USER_LOCATION",
                    name: "",
                    host: "",
                    ein: "",
                    category: "",
                    time: Date(),
                    images: [""],
                    coordinate: (locationManager?.location!.coordinate)!,
                    description: "description"
                ))
                
                for eventTypesDocument in querySnapshot!.documents {
                    let queries = queryBounds.map { bound -> Query in
                        return db.collection("EventTypes/\(eventTypesDocument.documentID)/Events")
                            .order(by: "geohash")
                            .start(at: [bound.startValue])
                            .end(at: [bound.endValue])
                    }
                    
                    func getDocumentsCompletion(snapshot: QuerySnapshot?, error: Error?) -> () {
                        guard let documents = snapshot?.documents else {
                            print("Unable to fetch snapshot data. \(String(describing: error))")
                            return
                        }
                        
                        for document in documents {
                            print("\(mapAnnotationsList.count) NAMENAMENAME: \(document.get("name"))")
                            
                            let id = document.documentID
                            let host = document.get("host") as? String ?? "Host unavailable"
                            let ein = document.get("ein") as? String ?? "No valid ein"
                            let name = document.get("name") as? String ?? "no name"
                            let description = document.get("description") as? String ?? "No description!"
                            _ = document.get("attendees") as? [String] ?? [String]()
                            let time = document.get("time") as? Timestamp
                            let imageURL = document.get("images") as? [String] ?? [String]()
                            let location = document.get("location") as? GeoPoint ?? GeoPoint(latitude: 0, longitude: 0)
                            
                            self.queriedEventsList.append(EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                ein: ein,
                                category: eventTypesDocument.documentID,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location.latitude), longitude: (location.longitude)),
                                description: description
                            ))
                            
                            self.mapAnnotationsList.append(EventInformationModel(
                                FIRDocID: id,
                                name: name,
                                host: host,
                                ein: ein,
                                category: eventTypesDocument.documentID,
                                time: time?.dateValue() ?? Date(),
                                images: imageURL,
                                coordinate: CLLocationCoordinate2D(latitude: (location.latitude), longitude: (location.longitude)),
                                description: description
                            ))
                        }
                        
                        queriedEventsList.sort {
                            $0.time < $1.time
                        }

                    }
                    
                    // After all callbacks have executed, matchingDocs contains the result. Note that this
                    // sample does not demonstrate how to wait on all callbacks to complete.
                    for query in queries {
                        query.getDocuments(completion: getDocumentsCompletion)
                    }
                }
            }
            
        }
    }
    
    var locationManager: CLLocationManager?
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            guard let locationManager = locationManager else { return }
            checkLocationAuthorization()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startEventDate: Date? = dateFormatter.date(from: "2022-07-15")
            let endEventDate: Date? = dateFormatter.date(from: "2022-07-16")
            updateQueriedEventsList(latitude: (locationManager.location?.coordinate.latitude)!, longitude: (locationManager.location?.coordinate.longitude)!, radiusInMi: 10, startEventDate: startEventDate!, endEventDate: endEventDate!)

        } else {
            
        }
    }
    
    private func checkLocationAuthorization() {
        //        if locationManager is not nil, proceed. Otherwise, early exit out of function
        guard let locationManager = locationManager else { return }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted cuz of parental controls?")
        case .denied:
            print("location denied, enable in phone settings")
        case .authorizedAlways, .authorizedWhenInUse:
            self.region = MKCoordinateRegion(center: locationManager.location?.coordinate ?? CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
        @unknown default:
            break
        }
    }
    
}

extension LocationTrackerViewModel: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
        else { return }
        DispatchQueue.main.async {
            self.checkLocationAuthorization()
        }
    }
}
