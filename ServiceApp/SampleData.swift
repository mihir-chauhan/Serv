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
    EventInformationModel(name: "Cupterino High School", category: "Environmental", coordinate: .init(latitude: 37.3194, longitude: -122.0091)),
    EventInformationModel(name: "Lynbrook High School", category: "Environmental", coordinate: .init(latitude: 37.3006, longitude: -122.0047)),
    EventInformationModel(name: "Valleyfair", category: "Environmental", coordinate: .init(latitude: 37.3253, longitude: -121.9458)),
    EventInformationModel(name: "Ortega Park", category: "Environmental", coordinate: .init(latitude: 37.3422, longitude: -122.0256)),
    EventInformationModel(name: "Memorial Park", category: "Environmental", coordinate: .init(latitude: 37.3238, longitude: -122.0447)),
    EventInformationModel(name: "Stiver Lagoon", category: "Environmental", coordinate: .init(latitude: 37.5424, longitude: -121.9600), description: "The City of Fremont, Environmental Services Division is recruiting at least 9 experienced volunteers, and 9 inexperienced volunteers to help with Habitat Restoration at Stivers Lagoon. Ages 14 and up. This is a great opportunity to have a positive impact on the environment and to earn community service hours.")
]
