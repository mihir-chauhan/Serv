//
//  SampleData.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import Foundation

private var pointsOfInterest2 = [
    AnnotationItem(name: "Facebook HQ", coordinate: .init(latitude: 37.3194, longitude: -122.0091)),
    AnnotationItem(name: "Lynbrook High School", coordinate: .init(latitude: 37.3006, longitude: -122.0047)),
    AnnotationItem(name: "Valleyfair", coordinate: .init(latitude: 37.3253, longitude: -121.9458))
]

// will use Firebase to host these info
var pointsOfInterest = [
    EventInformationModel(name: "Facebook HQ", category: "Environmental", coordinate: .init(latitude: 37.3194, longitude: -122.0091)),
    EventInformationModel(name: "Lynbrook High School", category: "Environmental", coordinate: .init(latitude: 37.3006, longitude: -122.0047)),
    EventInformationModel(name: "Valleyfair", category: "Environmental", coordinate: .init(latitude: 37.3253, longitude: -121.9458)),
    EventInformationModel(name: "Ortega Park", category: "Environmental", coordinate: .init(latitude: 37.3422, longitude: -122.0256)),
    EventInformationModel(name: "Memorial Park", category: "Environmental", coordinate: .init(latitude: 37.3238, longitude: -122.0447)),
]
