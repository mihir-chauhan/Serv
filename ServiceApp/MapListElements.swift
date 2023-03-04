//
//  MapListElements.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import CoreLocation
import MapKit

struct MapListElements: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var searchTerm = ""
    @Binding var eventPresented: EventInformationModel
    @EnvironmentObject var locationVM: LocationTrackerViewModel
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Nearby Events")
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
                                        
                                        let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                        hapticResponse.impactOccurred()
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
                                locationVM.searchRadius = 10
                            } label: {
                                Text("~10 mi")
                                if(locationVM.searchRadius == 10) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                locationVM.searchRadius = 20
                            } label: {
                                Text("~20 mi")
                                if(locationVM.searchRadius == 20) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                locationVM.searchRadius = 40
                            } label: {
                                Text("~40 mi")
                                if(locationVM.searchRadius == 40) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                locationVM.searchRadius = 60
                            } label: {
                                Text("~60 mi")
                                if(locationVM.searchRadius == 60) {
                                    Image(systemName: "checkmark.circle")
                                }
                            }
                            Button {
                                locationVM.searchRadius = 100
                            } label: {
                                Text("~100 mi")
                                if(locationVM.searchRadius == 100) {
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
                        DatePicker("Start", selection: $locationVM.startRangeDate, in: Date()...locationVM.endRangeDate.addingTimeInterval(-86400), displayedComponents: [.date])
                            .labelsHidden()
                        
                        Spacer()
                            .frame(width: 7)
                        Text("to")
                        Spacer()
                            .frame(width: 7)
                        DatePicker("End", selection: $locationVM.endRangeDate, in: locationVM.startRangeDate.addingTimeInterval(86400*2)..., displayedComponents: [.date])
                            .labelsHidden()
                    }
                }
                
                if self.searchTerm.isEmpty {
                    List(locationVM.filteredEventsList) { event in
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
                    List(locationVM.filteredEventsList.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})) { event in
                        
                        Button(action: {
                            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                            hapticResponse.impactOccurred()
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
        
        .onChange(of: locationVM.startRangeDate) { _ in
            updateDateFilter()
        }
        .onChange(of: locationVM.endRangeDate) { _ in
            updateDateFilter()
        }
        .onChange(of: locationVM.searchRadius) { _ in
            queryBasedOnSearchParams()
        }
    }
    func sortByDistance() {
        self.locationVM.filteredEventsList.sort {
            let userCoordinate = CLLocation(latitude: (locationVM.locationManager?.location?.coordinate.latitude)!, longitude: (locationVM.locationManager?.location?.coordinate.longitude)!)
            let distanceBetweenTwoPoints1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let distanceBetweenTwoPoints2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            
            self.locationVM.filteredEventsList.sort(by: { _,_ in distanceBetweenTwoPoints1.distance(from: userCoordinate) < distanceBetweenTwoPoints2.distance(from: userCoordinate) })
            
            return true
        }
        
    }
    
    func updateDateFilter() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        locationVM.applyDateRangeFilters(startRange: (dateFormatter.date(from: dateFormatter.string(from: locationVM.startRangeDate)))!, endRange: (dateFormatter.date(from: dateFormatter.string(from: locationVM.endRangeDate)))!)
    }
    
    
    func queryBasedOnSearchParams() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        locationVM.updateQueriedEventsList(latitude: (locationVM.locationManager?.location?.coordinate.latitude)!, longitude: (locationVM.locationManager?.location?.coordinate.longitude)!, radiusInMi: locationVM.searchRadius, startEventDate: (dateFormatter.date(from: dateFormatter.string(from: locationVM.startRangeDate)))!, endEventDate: (dateFormatter.date(from: dateFormatter.string(from: locationVM.endRangeDate)))!, limitResults: false)
    }
}

struct ListCellView: View {
    @EnvironmentObject var locationVM: LocationTrackerViewModel
    var event: EventInformationModel
    
    var distance: CLLocationDistance {
        get {
            return (CLLocation(latitude: event.coordinate.latitude, longitude: event.coordinate.longitude).distance(from: CLLocation(latitude: (locationVM.locationManager?.location?.coordinate.latitude)!, longitude: (locationVM.locationManager?.location?.coordinate.longitude)!))/1609.344)
        }
    }
    
    var body: some View {
        HStack {
            Text(event.name)
            Spacer(minLength: 10)
            Text(String(format: "%.2f", distance) + " mi." + " | " + event.time.dateToString())
                .font(.caption)
        }
    }
}

