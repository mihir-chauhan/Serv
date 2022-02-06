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
    @StateObject var viewModel = LocationTrackerViewModel()
    @ObservedObject var results = FirestoreCRUD()
    
    var body: some View {
        ZStack {
        VStack(alignment: .leading) {
            Text("Events")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .padding()
            HStack {
                HStack {
                    TextField("Search Events...", text: $searchTerm)
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
                
                
                Menu {
                    Button("Date", action: sortByDate)
                } label: {
                    RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        .overlay(
                            Image("funnel")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(#colorLiteral(red: 0.9490196078, green: 0.968627451, blue: 0.9725490196, alpha: 1)))
                        )
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
            return distanceInMiles
        }
    }
    var body: some View {
        HStack {
            Text(event.name)
            Spacer(minLength: 10)
            Text(String(format: "%.2f", distance) + " mi.")
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
