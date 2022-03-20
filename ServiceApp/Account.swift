//
//  Account.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import SwiftUICharts

struct Account: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let maxHeight = display.height / 3.1
    var topEdge: CGFloat
    
    @State var offset: CGFloat = 0
//    var uidInfoStored: String {
//            get {
//                return ContentView().uidStoredInfo
//                }
//        }
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                GeometryReader { proxy in
                    if #available(iOS 15.0, *) {
                        TopBar(topEdge: topEdge, offset: $offset, maxHeight: maxHeight)
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: display.width, height: getHeaderHeight(), alignment: .bottom)
                            .background(Color("accountsbarcolor"), in: CustomCorner(corners: [.bottomRight], radius: getCornerRadius()))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .overlay(
                    HStack {
                        AsyncImage(url: viewModel.decodeUserInfo()?.photoURL ?? UserInfoFromAuth().photoURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                            case .success(let image):
                                image.resizable()
                                    .frame(width: 45, height: 45)
                                    .aspectRatio(contentMode: .fit)
                                    .clipShape(Circle())
                                    .opacity(Double(topBarTitleOpacity()))
                            case .failure:
                                Image(systemName: "photo")
                            @unknown default:
                                ProgressView()
                            }
                        }
                            .frame(width: 45, height: 45)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .opacity(Double(topBarTitleOpacity()))
                        
                        Text(viewModel.decodeUserInfo()?.displayName ?? "John Smith")
                            .fontWeight(.bold)
                            .font(.headline)
                            .opacity(Double(topBarTitleOpacity()))
                        Spacer()

                    }
                        .padding(.horizontal)
                        .frame(height: 60)
                        .foregroundColor(.white)
                        .padding(.top, topEdge)
                    , alignment: .top
                )
                .frame(height: maxHeight)
                .offset(y: -offset)
                .zIndex(1)

                VStack(spacing: 15) {
                    Image(uiImage: UIImage(data: generateQRCode(from: user_uuid)!)!)
                        .resizable()
                        .frame(width: 290, height: 290, alignment: .center)
                        .font(.system(size: 30, weight: .bold, design: .rounded))

                    BarChartView(data: ChartData(points: [8,13,20,12,14,17,7,13,16]), title: "Service Hours per Week", legend: "Hours", form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, animatedToBack: true).padding(10)

                    PieChartView(data: [8, 23, 54, 32], title: "Service Categories", form: ChartForm.extraLarge, dropShadow: false).padding(10)
                    
//                    BarChartView(data: ChartData(points: [8,13,20,12,14,17,7,13,16]), title: "Service Hours per Week", legend: "Hours", form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, animatedToBack: true).padding(10)
                    
                    Settings().padding()
                }
                .zIndex(0)
            }
            .padding(.bottom, 100)
            .modifier(OffsetModifier(offset: $offset))
        }
        .coordinateSpace(name: "SCROLL")
        
        
    }
    
    func getHeaderHeight() -> CGFloat {
        let topHeight = maxHeight + offset
        return topHeight > (80 + topEdge)  ? topHeight : (80 + topEdge)
    }
    
    func getCornerRadius() -> CGFloat {
        let progress = -offset / (maxHeight - (80 + topEdge))
        
        let value = 1 - progress
        
        let radius = value * 50
        
        return offset < 0 ? radius : 50
    }
    
    func topBarTitleOpacity() -> CGFloat {
        let progress = -(offset + 70) / (maxHeight - (80 + topEdge))
        
        let opacity = 1 - progress
        
        return 1 - opacity
    }
    
    
    private func generateQRCode(from string: String) -> Data? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output).pngData()!
            }
        }
        
        return nil
    }
    
}

struct TopBar: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var topEdge: CGFloat
    @Binding var offset: CGFloat
    var maxHeight: CGFloat

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AsyncImage(url: viewModel.decodeUserInfo()?.photoURL ?? UserInfoFromAuth().photoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .frame(width: 80, height: 80)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    ProgressView()
                }
            }
            
                
            Text(viewModel.decodeUserInfo()?.displayName ?? "John Smith")
                .font(.largeTitle.bold())
            
            Text("My name is John Smith and I am a high school junior. I love to volunteer at various food drives to help pass out food as well as cleaning up at local shorelines!")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.white.opacity(0.8))
        }
        .opacity(Double(getOpacity()))
    }
    
    func getOpacity() -> CGFloat {
        let progress = -offset / 70
        let opacity = 1 - progress
        return offset < 0 ? opacity : 1
    }
}

struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct OffsetModifier: ViewModifier {
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .overlay(
                GeometryReader{proxy -> Color in
                    
                    let minY = proxy.frame(in: .named("SCROLL")).minY
                    
                    DispatchQueue.main.async {
                        self.offset = minY
                    }
                    
                    return Color.clear
                },
                alignment: .top
            )
    }
}
