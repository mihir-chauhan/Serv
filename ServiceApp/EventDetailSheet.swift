//
//  EventDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI
import MapKit

struct EventDetailSheet: View {
    @EnvironmentObject var cardData: ScheduleModel
    
    var animation: Namespace.ID
    @State private var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.3194, longitude: -122.0091), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    var body: some View {
        if let card = cardData.title, cardData.showDetail {
            if #available(iOS 15.0, *) {
                VStack() {
                    Image(cardData.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: cardData.title, in: animation)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .cornerRadius(15)
                                .matchedGeometryEffect(id: "asdfadsdc", in: animation)
                                .ignoresSafeArea()
                        )
                    Map(coordinateRegion: $region)
                                .frame(width: 400, height: 300)
                    Spacer()
                }
                .background(CustomMaterialEffectBlur())
            } else {
                // Fallback on earlier versions
                VStack() {
                    Image(cardData.image!)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .matchedGeometryEffect(id: cardData.title, in: animation)
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.white, Color.gray, Color.white]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .cornerRadius(15)
                                .matchedGeometryEffect(id: "asdfadsdc", in: animation)
                                .ignoresSafeArea()
                        )
                    Map(coordinateRegion: $region)
                                .frame(width: 400, height: 300)
                    Spacer()
                }
                .background(CustomMaterialEffectBlur())
            }
        }
    }
}
