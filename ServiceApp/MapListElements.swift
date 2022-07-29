//
//  MapListElements.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import CoreLocation
import MapKit
import Combine
import FirebaseFirestore

struct MapListElements: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var searchTerm = ""
    @Binding var eventPresented: EventInformationModel
    @StateObject var viewModel = LocationTrackerViewModel()
    @State private var startEventDate = Date()
    @State private var endEventDate = Date().addingTimeInterval(86400 * 7)
    @State private var selectedRadius: Int = 0
    @State private var searchResults = [EventInformationModel]()
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Events")
                    .font(.system(size: 35))
                    .fontWeight(.bold)
                    .padding()
                VStack {
                    HStack {
                        HStack {
                            TextField("Event Name", text: $searchTerm)
                            if !searchTerm.isEmpty {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Color(.systemGray2))
                                    .padding(.horizontal, 3)
                                    .onTapGesture {
                                        self.searchTerm = ""
                                    }
                                
                            }
                            
                        }.padding(10)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                        
                        
                        Spacer()
                            .frame(width: 10)
                        
                        Menu {
                            Button {
                                selectedRadius = 0
                            } label: {
                                Text("10 mi")
                                if(selectedRadius == 0) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            Button {
                                selectedRadius = 1
                            } label: {
                                Text("20 mi")
                                if(selectedRadius == 1) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            Button {
                                selectedRadius = 2
                            } label: {
                                Text("40 mi")
                                if(selectedRadius == 2) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            Button {
                                selectedRadius = 3
                            } label: {
                                Text("60 mi")
                                if(selectedRadius == 3) {
                                    Image(systemName: "checkmark")
                                }
                            }
                            Button {
                                selectedRadius = 4
                            } label: {
                                Text("100 mi")
                                if(selectedRadius == 4) {
                                    Image(systemName: "checkmark")
                                }
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                                .overlay(
                                    Image(systemName: "arrow.left.and.right.circle")
                                        .renderingMode(.original)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color(.systemGray2))
                                )
                        }
                        
                        
                    }.padding(.top, 10)
                        .padding(.horizontal, 20)
                    
                    HStack {
                        DatePicker("Start", selection: $startEventDate, in: Date()..., displayedComponents: [.date])
                            .labelsHidden()
                            .id(UUID().uuidString)
                        
                        Spacer()
                            .frame(width: 7)
                        Text("to")
                        Spacer()
                            .frame(width: 7)
                        DatePicker("End", selection: $endEventDate, in: startEventDate.addingTimeInterval(86400)..., displayedComponents: [.date])
                            .labelsHidden()
                            .id(UUID().uuidString)
                    }
                }
                
                if self.searchTerm.isEmpty {
                    List(searchResults) { event in
                        Button(action: {
                            withAnimation(.spring()) {
                                self.sheetObserver.eventDetailData = event
                                self.sheetObserver.sheetMode = .half
                            }
                        }) {
                            ListCellView(event: event)
                            
                        }.padding(.vertical)
                    }.padding(.vertical)
                }
                else {
                    //                    List(results.allFIRResults.filter({(CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude).distance(from: CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.longitude))/1609.344) <= CGFloat(Int(searchTerm)!)})) { event in
                    List(searchResults.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})) { event in
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                self.sheetObserver.eventDetailData = event
                                self.sheetObserver.sheetMode = .half
                            }
                        }) {
                            ListCellView(event: event)
                            
                        }.padding(.vertical)
                    }.padding(.vertical)
                }
            }
            CloseButton(sheetMode: $sheetObserver.sheetMode)
        }
        .onAppear() {
            queryBasedOnSearchParams();
        }
    }
    
    func sortByDate() {
        self.searchResults.sort {
            $0.time > $1.time
        }
    }
    func sortByDistance() {
        self.searchResults.sort {
            let userCoordinate = CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.latitude)
            let distanceBetweenTwoPoints1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let distanceBetweenTwoPoints2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            
            self.searchResults.sort(by: { _,_ in distanceBetweenTwoPoints1.distance(from: userCoordinate) < distanceBetweenTwoPoints2.distance(from: userCoordinate) })
            
            return true
        }
        
    }
    
    func queryBasedOnSearchParams() {
        let db = Firestore.firestore()
        
        let formatter = DateFormatter()
        let dateFormatter = DateFormatter()

        formatter.dateFormat = "MMMM d, yyyy HH:mm:ss"

        let startTime: Date = formatter.date(from: dateFormatter.string(from: startEventDate)) ?? Date(timeIntervalSince1970: 0)
        let startTimestamp: Timestamp = Timestamp(date: startTime)

        let endTime: Date = formatter.date(from: dateFormatter.string(from: endEventDate)) ?? Date()
        let endTimestamp: Timestamp = Timestamp(date: endTime)

        
        let distance = 3.0
        
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()

        var currentLocation: CLLocation!
        
        if
           CLLocationManager.authorizationStatus() == .authorizedWhenInUse ||
           CLLocationManager.authorizationStatus() ==  .authorizedAlways
        {
            currentLocation = locManager.location
        }
        else {
            currentLocation = CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.longitude)
        }

        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude

        let lat = 0.0144927536231884
        let lon = 0.0181818181818182

        let lowerLat = latitude - (lat * distance)
        let lowerLon = longitude - (lon * distance)

        let greaterLat = latitude + (lat * distance)
        let greaterLon = longitude + (lon * distance)

        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        
        print(GeoPoint(latitude: latitude, longitude: longitude))
        
        print(lesserGeopoint)
        print(greaterGeopoint)
        
        db.collection("EventTypes").getDocuments() { (querySnapshot, err) in
            if let err = err
            {
                print("Error getting documents: \(err)");
            }
            else
            {
                for document in querySnapshot!.documents {
                    
                    db.collection("EventTypes/\(document.documentID)/Events")
                        .whereField("latitude",  isGreaterThan: lesserGeopoint.latitude  )
                        .whereField("latitude",  isLessThan:    greaterGeopoint.latitude )
                        .whereField("longitude", isGreaterThan: lesserGeopoint.longitude )
                        .whereField("longitude", isLessThan:    greaterGeopoint.longitude).getDocuments() {
                        (querySnapshot, err) in
                        if let err = err {
                            print("Error getting documents: \(err)")
                        } else {
                            for document in querySnapshot!.documents {
                                let dataDescription = document.data()["location"]
                                print("\(document.documentID) => \(dataDescription)")

                            }
                        }
                        
                    }
                }
            }
            
        }
    }
}

struct ListCellView: View {
    @StateObject var viewModel = LocationTrackerViewModel()
    var event: EventInformationModel
    
    var distance: CLLocationDistance {
        get {
            let eventCoordinate = CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude)
            let userCoordinate = CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.longitude)
            let distanceBetweenTwoPoints = eventCoordinate.distance(from: userCoordinate)
            
            let distanceInMiles = distanceBetweenTwoPoints/1609.344
            return (CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude).distance(from: CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.longitude))/1609.344)
        }
    }
    
    var date: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/YY"
            return dateFormatter.string(from: event.time)
        }
    }
    
    var body: some View {
        HStack {
            Text(event.name)
            Spacer(minLength: 10)
            Text(String(format: "%.2f", distance) + " mi." + " | " + date)
                .font(.caption)
        }.onAppear {
            viewModel.checkIfLocationServicesIsEnabled()
        }
    }
    
}

struct CloseButton: View {
    @Binding var sheetMode: SheetMode
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    UIApplication.shared.endEditing()
                    self.sheetMode = .quarter
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.systemGray2))
                        .padding(12)
                }
            }
            .padding(.top, 5)
            Spacer()
        }
    }
}

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
