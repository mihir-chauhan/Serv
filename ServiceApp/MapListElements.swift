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
import GeoFireUtils

struct MapListElements: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var searchTerm = ""
    @Binding var eventPresented: EventInformationModel
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @State private var startEventDate = Date()
    @State private var endEventDate = Date().addingTimeInterval(86400 * 7)
    @State private var selectedRadius: Double = 10.0
    
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
                            .foregroundColor(Color.primary)
                            .background(Color.white.opacity(0.5))
                            .cornerRadius(12)
                        
                        
                        Spacer()
                            .frame(width: 10)
                        
                        Menu {
                            Button {
                                viewModel.searchRadius = 10
                            } label: {
                                Text("~10 mi")
                                if(viewModel.searchRadius == 10) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                viewModel.searchRadius = 20
                            } label: {
                                Text("~20 mi")
                                if(viewModel.searchRadius == 20) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                viewModel.searchRadius = 40
                            } label: {
                                Text("~40 mi")
                                if(viewModel.searchRadius == 40) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                viewModel.searchRadius = 60
                            } label: {
                                Text("~60 mi")
                                if(viewModel.searchRadius == 60) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                viewModel.searchRadius = 100
                            } label: {
                                Text("~100 mi")
                                if(viewModel.searchRadius == 100) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                        } label: {
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(Color.white.opacity(0.5))
                                .overlay(
                                    Image(systemName: "arrow.left.and.right.circle")
                                        .renderingMode(.original)
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .foregroundColor(Color.primary.opacity(0.7))
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
                    List(viewModel.queriedEventsList) { event in
                        Button(action: {
                            withAnimation(.spring()) {
                                self.sheetObserver.eventDetailData = event
                                self.sheetObserver.sheetMode = .half
                            }
                        }) {
                            ListCellView(event: event)
                            
                        }.padding(.vertical)
                    }.padding(.bottom, 130)
                }
                else {
                    List(viewModel.queriedEventsList.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})) { event in
                        
                        Button(action: {
                            withAnimation(.spring()) {
                                self.sheetObserver.eventDetailData = event
                                self.sheetObserver.sheetMode = .half
                            }
                        }) {
                            ListCellView(event: event)
                            
                        }.padding(.vertical)
                    }.padding(.bottom, 130)
                }
            }
            CloseButton(sheetMode: $sheetObserver.sheetMode)
        }
//        .onAppear() {
//            selectedRadius = viewModel.searchRadius
//
//            //invokes onChanged; maybe bad
//        }
        .onChange(of: startEventDate) { _ in
                        
        }
        .onChange(of: endEventDate) { _ in
                        
        }
        .onChange(of: selectedRadius) { _ in
            queryBasedOnSearchParams()
        }
    }
    func sortByDistance() {
        self.viewModel.queriedEventsList.sort {
            let userCoordinate = CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.latitude)
            let distanceBetweenTwoPoints1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let distanceBetweenTwoPoints2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            
            self.viewModel.queriedEventsList.sort(by: { _,_ in distanceBetweenTwoPoints1.distance(from: userCoordinate) < distanceBetweenTwoPoints2.distance(from: userCoordinate) })
            
            return true
        }
        
    }
    
    func queryBasedOnSearchParams() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        viewModel.updateQueriedEventsList(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.longitude, radiusInMi: viewModel.searchRadius, startEventDate: (dateFormatter.date(from: dateFormatter.string(from: startEventDate)))!, endEventDate: (dateFormatter.date(from: dateFormatter.string(from: endEventDate)))!)
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
