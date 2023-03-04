//
//  RecommendedView.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/1/22.
//

import SwiftUI
import SDWebImageSwiftUI
import MapKit

struct RecommendedView: View {
    @EnvironmentObject var locationVM: LocationTrackerViewModel
    @EnvironmentObject var tabBarController: TabBarController
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var viewRendered = false
    @State var placeHolderUIImage: UIImage?
    
    var data: EventInformationModel
    var emoji: String
    
    var body: some View {
        if !self.viewRendered {
            ProgressView().frame(width: 290, height: 250)
                .task {
                    FIRCloudImages.getImage(gsURL: data.images![0], eventID: data.FIRDocID!, eventDate: data.time) { image in
                        self.placeHolderUIImage = image!
                        self.viewRendered = true
                    }
                    
                    print("cache size", URLCache.shared.memoryCapacity / 1024)
                }
        }
        else {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                RoundedRectangle(cornerRadius: 20)
                    .foregroundColor(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.25)))
                VStack(alignment: .leading) {
                    if let imageLoaded = self.placeHolderUIImage {
                        Image(uiImage: imageLoaded)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 290, height: 145)
                            .clipped()
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                    }
                    
                    HStack {
                        Text(data.name)
                            .font(.system(size: 22).bold())
                            .font(.headline)
                            .padding(.leading, 15)
                        Spacer()
                        Text(self.emoji)
                            .font(.system(size: 25))
                            .padding(.trailing, 15)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(data.category)
                            .font(.caption)
                            .bold()
                        Spacer()
                        Text(data.time.dateToString())
                            .font(.system(size: 10))
                            .font(.caption2)
                    }.padding(15)
                }
                
            }
            .frame(width: 290, height: 250)
            .onTapGesture {
                let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                hapticResponse.impactOccurred()
                
                self.locationVM.recommendedEventFromHomePage = data
                self.sheetObserver.sheetMode = .half
                self.sheetObserver.eventDetailData = data
                self.locationVM.region = MKCoordinateRegion(center: data.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                self.tabBarController.selectedIndex = .map
            }
        }
    }
}
