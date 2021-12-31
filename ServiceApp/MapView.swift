//
//  MapView.swift
//  ServiceApp
//
//  Created by mimi on 12/24/21.
//

import SwiftUI
import MapKit

struct MapView1: View {
    @State private var sheetMode: SheetMode = .quarter
//    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 40.71, longitude: -82), span: MKCoordinateSpan(latitudeDelta: 0.9, longitudeDelta: 0.9))
    @State var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (MapView().mapView.userLocation.location?.coordinate.latitude) ?? 0, longitude: (MapView().mapView.userLocation.location?.coordinate.longitude) ?? 0), span: MKCoordinateSpan())
    @State var tracking: MapUserTrackingMode = .follow
    private var pointsOfInterest1 = [
        AnnotationItem(name: "Facebook HQ", coordinate: .init(latitude: 37.3194, longitude: -122.0091)),
        AnnotationItem(name: "Lynbrook High School", coordinate: .init(latitude: 37.3006, longitude: -122.0047)),
        AnnotationItem(name: "Valleyfair", coordinate: .init(latitude: 37.3253, longitude: -121.9458))
    ]
    var body: some View {
        ZStack {
        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $tracking, annotationItems: pointsOfInterest) { pin in
            MapAnnotation(coordinate: pin.coordinate) {
                Button(action: {
                    withAnimation(.spring()) {
                        sheetMode = .half
                        self.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: pin.coordinate.latitude - 0.01, longitude: pin.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
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
            HalfSheetModalView(sheetMode: $sheetMode)
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MapView: UIViewRepresentable {
    @ObservedObject var locationManager = LocationManager()
    let mapView = MKMapView()
    func makeUIView(context: Context) -> some MKMapView {
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        locationManager
        
        return mapView
    }
    
    func updateUIView(_ view: UIViewType, context: Context) { }
    
    func makeCoordinator() -> Coordinator { Coordinator() }
    
    class Coordinator: NSObject, MKMapViewDelegate, ObservableObject { }
}


