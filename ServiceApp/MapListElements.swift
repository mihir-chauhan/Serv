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

struct MapListElements: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var searchTerm = ""
    @Binding var eventPresented: EventInformationModel
    @StateObject var viewModel = LocationTrackerViewModel()
    @ObservedObject var results = FirestoreCRUD()
    @State private var startEventDate = Date()
    @State private var endEventDate = Date()
    @State private var showPicker = false

    var body: some View {
        ZStack {
            VStack(alignment: .leading) {
                Text("Events")
                    .font(.system(size: 35))
                    .fontWeight(.bold)
                    .padding()
                HStack {
                    HStack {
                        TextField("Radius (mi)", text: $searchTerm)
                            .keyboardType(.numberPad)
                        if !searchTerm.isEmpty {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(.systemGray2))
                                .padding(.horizontal, 3)
                                .onTapGesture {
                                    UIApplication.shared.endEditing()
                                }
                        }
                    }.padding(10)
                        .background(Color.white.opacity(0.5))
                        .cornerRadius(12)

                    VStack {
                        DatePicker("Start", selection: $startEventDate, in: Date()..., displayedComponents: [.date])
                            .labelsHidden()
                            .frame(width: 100, height: 30, alignment: .center)

                        DatePicker("End", selection: $endEventDate, in: startEventDate..., displayedComponents: [.date])
                            .labelsHidden()
                            .frame(width: 100, height: 30, alignment: .center)
                    }

                }.padding(.top, 10)
                    .padding(.horizontal, 20)
                if self.searchTerm.isEmpty {
                    List(results.allFIRResults) { event in
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
                    List(results.allFIRResults.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})) { event in

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
    }
    
    func sortByDate() {
        self.results.allFIRResults.sort {
            $0.time > $1.time
        }
    }
    func sortByDistance() {
        self.results.allFIRResults.sort {
            let userCoordinate = CLLocation(latitude: viewModel.region.center.latitude, longitude: viewModel.region.center.latitude)
            let distanceBetweenTwoPoints1 = CLLocation(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            let distanceBetweenTwoPoints2 = CLLocation(latitude: $1.coordinate.latitude, longitude: $1.coordinate.longitude)
            
            self.results.allFIRResults.sort(by: { _,_ in distanceBetweenTwoPoints1.distance(from: userCoordinate) < distanceBetweenTwoPoints2.distance(from: userCoordinate) })
            
            return true
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
