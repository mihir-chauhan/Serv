//
//  MapHelpers.swift
//  ServiceApp
//
//  Created by mimi on 12/25/21.
//

import MapKit
import SwiftUI

struct AnnotationItem: Identifiable {
    var id = UUID()
    var name: String
    var coordinate: CLLocationCoordinate2D
}

// unused
struct Pin: Identifiable {
    var id = UUID().uuidString
    var location: CLLocation
    
}

class LocationManager: NSObject, ObservableObject {
    private let locationManager = CLLocationManager()
    @Published var pins: [Pin] = []
    @Published var location: CLLocation?
    
    override init() {
        super.init()
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
}
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last
            else { return }
        DispatchQueue.main.async {
            self.location = location
            print(location.coordinate)
            self.pins.append(Pin(location: location))
            
        }
    }
}





