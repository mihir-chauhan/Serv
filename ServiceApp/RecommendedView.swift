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
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @EnvironmentObject var tabBarController: TabBarController
    @EnvironmentObject var sheetObserver: SheetObserver
    @Environment(\.colorScheme) var colorScheme
    @State var viewRendered = false
    @State var placeHolderUIImage: UIImage?
    var data: EventInformationModel
    var emoji: String
    var dateToString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            let stringDate = dateFormatter.string(from: data.time)
            return stringDate
        }
    }
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
                
//                    .foregroundColor(colorScheme == .light ? Color.neuWhite : Color.neuWhite.opacity(0.25))
                    .foregroundColor(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.25)))
                VStack(alignment: .leading) {
                    if let imageLoaded = self.placeHolderUIImage {
                        Image(uiImage: imageLoaded)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 290, height: 145)
                            .clipped()
//                            .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.25)))
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                    }
                    
                    
                    HStack {
                        Text(data.name)
                            .font(.system(size: 22).bold())
                            .font(.headline)
                            .padding(15)
                        Spacer()
                        Text(self.emoji)
                            .font(.system(size: 25))
                            .padding(.trailing, 7)
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text(data.category)
                            .font(.caption)
                            .bold()
                        Spacer()
                        Text(self.dateToString)
                            .font(.system(size: 10))
                            .font(.caption2)
                    }.padding(15)
                }
                
            }
            .frame(width: 290, height: 250)
            .onTapGesture {
                self.viewModel.recommendedEventFromHomePage = data
                self.sheetObserver.sheetMode = .half
                self.sheetObserver.eventDetailData = data
                self.viewModel.region = MKCoordinateRegion(center: data.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
                tabBarController.selectedIndex = .map
            }
        }
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let w = geometry.size.width
                let h = geometry.size.height

                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
                
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
                path.closeSubpath()
            }
            .fill(self.color)
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}


struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
