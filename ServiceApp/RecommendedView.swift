//
//  RecommendedView.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/1/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecommendedView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @Environment(\.colorScheme) var colorScheme
    @State var viewRendered = false
    @State var placeHolderUIImage: UIImage?
    var data: EventInformationModel
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
                .onAppear {
                    FIRCloudImagesWithCache.getImage(gsURL: data.images![0]) { image in
                        self.placeHolderUIImage = image!
                        self.viewRendered = true
                    }
                    
                    print("cache size", URLCache.shared.memoryCapacity / 1024)
                }
        }
        else {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                RoundedRectangle(cornerRadius: 20)
                
                    .foregroundColor(colorScheme == .light ? Color(#colorLiteral(red: 0.9688304554, green: 0.9519491526, blue: 0.8814709677, alpha: 1)) : Color(#colorLiteral(red: 48/255, green: 48/255, blue: 48/255, alpha: 1)))
                VStack(alignment: .leading) {
                    if let imageLoaded = self.placeHolderUIImage {
                        Image(uiImage: imageLoaded)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 290, height: 145)
                            .clipped()
                            .background(Color(.systemGray4))
                            .cornerRadius(20, corners: [.topLeft, .topRight])
                    }
                    
                    
                    HStack {
                        Text(data.name)
                            .font(.headline)
                            .padding(15)
                        Spacer()
                        Text(data.category == "Humanitarian" ? "🤝🏿" : "🌲").font(.system(size: 20)).padding(.trailing, 5)
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
                self.sheetObserver.sheetMode = .half
                EventDetailView(data: self.sheetObserver.eventDetailData, sheetMode: self.$sheetObserver.sheetMode)
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
