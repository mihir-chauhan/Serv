//
//  MapView.swift
//  ServiceApp
//
//  Created by mimi on 12/24/21.
//

import SwiftUI
import MapKit
import CoreLocation

struct MapView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @StateObject var viewModel = LocationTrackerViewModel()

    @State var tracking: MapUserTrackingMode = .follow
    
    var body: some View {
        ZStack {
            Map(coordinateRegion: $viewModel.region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: pointsOfInterest) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
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
            HalfSheetModalView()
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
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

final class LocationTrackerViewModel: NSObject, ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(), span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
    var locationManager: CLLocationManager?
    func checkIfLocationServicesIsEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager = CLLocationManager()
            locationManager?.desiredAccuracy = kCLLocationAccuracyBest
            locationManager?.delegate = self
            checkLocationAuthorization()
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
            self.region = MKCoordinateRegion(center: locationManager.location!.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2))
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
            print(location.coordinate)

            
        }
    }
}
