//
//  MapView.swift
//  ServiceApp
//
//  Created by mimi on 12/24/21.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (LocationTracker().mapView.userLocation.location?.coordinate.latitude) ?? 0, longitude: (LocationTracker().mapView.userLocation.location?.coordinate.longitude) ?? 0), span: MKCoordinateSpan())
    @State var tracking: MapUserTrackingMode = .follow
    var body: some View {
        ZStack {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: pointsOfInterest) { pin in
                MapAnnotation(coordinate: pin.coordinate) {
                    Button(action: {
                        withAnimation(.spring()) {
                            self.sheetObserver.sheetMode = .half
                            self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pin.coordinate.latitude - 0.02, longitude: pin.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
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
    }
}

struct LocationTracker: UIViewRepresentable {
    @ObservedObject private var locationManager = LocationManager()
    let mapView = MKMapView()
    func makeUIView(context: Context) -> some MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        self.locationManager
        
        return mapView
    }
    
    func updateUIView(_ view: UIViewType, context: Context) { }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, MKMapViewDelegate, ObservableObject { }
}


