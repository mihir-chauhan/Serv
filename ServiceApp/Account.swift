//
//  Account.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import SwiftUICharts

struct Account: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    let maxHeight = display.height / 3.1
    var topEdge: CGFloat
    
    @State var offset: CGFloat = 0
    @State var toggleEditInfoSheet: Bool = false
    @State var toggleFullScreenQR: Bool = false
    @State var toggleEventHistory: Bool = false
    @State var toggleAccountChange: Bool = false
    @State var signOutConfirmation = false

    @State var eventHistory: [EventHistoryInformationModel] = []
    @State var hoursSpent: [CGFloat] = []

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 15) {
                GeometryReader { proxy in
                    if #available(iOS 15.0, *) {
                        TopBar(topEdge: topEdge, offset: $offset, toggleEditInfoSheet: $toggleEditInfoSheet, maxHeight: maxHeight)
                            .padding()
                            .foregroundColor(.white)
                            .frame(width: display.width, height: getHeaderHeight(), alignment: .bottom)
                            .background(Color("colorSecondary"), in: CustomCorner(corners: [.bottomRight], radius: getCornerRadius()))
                    } else {
                        // Fallback on earlier versions
                    }
                }
                .overlay(
                    HStack {
                        Image(uiImage: documentDirectoryPath() ?? UIImage())
                            .resizable()
                            .frame(width: 45, height: 45)
                            .aspectRatio(contentMode: .fit)
                            .clipShape(Circle())
                            .opacity(Double(topBarTitleOpacity()))
                        
                        Text(authVM.decodeUserInfo()?.displayName ?? "John Smith")
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
                    Button(action: {
                        let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                        hapticResponse.impactOccurred()
                        toggleFullScreenQR.toggle()
                    }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.primary.opacity(0.05))
                        .frame(height: 75)
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                            Text("Your QR Code")
                                    .bold()
                                    .padding()
                            Spacer(minLength: 10)
                                Image(systemName: "qrcode")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }.padding(.horizontal)
                        )
                    }
                    
                    
                    Button(action: {
                        let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                        hapticResponse.impactOccurred()
                        toggleEventHistory.toggle()
                    }) {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(.primary.opacity(0.05))
                        .frame(height: 75)
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                            Text("Event History")
                                    .bold()
                                    .padding()
                            Spacer(minLength: 10)
                                Image(systemName: "clock.arrow.circlepath")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding()
                            }.padding(.horizontal)
                        )
                    }

                    LineGraph2(rawData: hoursSpent)
                        .frame(height: 220)
                        .padding(.bottom, 15)

                        .padding(.horizontal)
                        .task {
                            FirestoreCRUD().getNumberOfHours(uid: authVM.decodeUserInfo()!.uid, completion: { hoursSpent in
                                self.hoursSpent = hoursSpent
                            })
                        }
                        
                    
                    Button(action: {
                        let hapticResponse = UIImpactFeedbackGenerator(style: .heavy)
                        hapticResponse.impactOccurred()
                        toggleAccountChange.toggle()
                    }) {
                    RoundedRectangle(cornerRadius: 20)
                            .foregroundColor(colorScheme == .dark ? .red.opacity(0.2) : .red.opacity(0.10))
                        .frame(height: 65)
                        .padding(.horizontal)
                        .overlay(
                            HStack {
                            Text("Delete Account")
                                    .bold()
                                    .padding()
                                    .foregroundColor(.red)
                            Spacer(minLength: 10)
                                Image(systemName: "person.crop.circle.fill.badge.xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                                    .padding()
                                    .foregroundColor(.red)
                            }.padding(.horizontal)
                        )
                    }.alert(isPresented: $toggleAccountChange) {
                        Alert(
                                        title: Text("Are you sure you want to delete your account?"),
                                        message: Text("You will permanently lose your progress and data on this account"),
                                        primaryButton: .destructive(Text("Delete")) {
                                            authVM.deleteCurrentUser()
                                            authVM.signOut()
                                            // MARK: HERE
                                        },
                                        secondaryButton: .cancel()
                                    )
                    }
                    
                    Button(action: {
                        self.signOutConfirmation.toggle()
                    }) {
                        Text("Sign Out").foregroundColor(.red).bold()
                    }.alert(isPresented: $signOutConfirmation) {
                        Alert(
                            title: Text("Are you sure you want to sign out?"),
                            primaryButton: .destructive(Text("Sign out")) {
                                authVM.signOut()
                            },
                            secondaryButton: .cancel()
                            )
                    }
                
                    
                    .padding()
                }
                .zIndex(0)
            }
            .padding(.bottom, 100)
            .modifier(OffsetModifier(offset: $offset))
        }
        
        
        .coordinateSpace(name: "SCROLL")
        .fullScreenCover(isPresented: $toggleEditInfoSheet) {
            EditAccountDetails(toggleEditInfoSheet: $toggleEditInfoSheet)
        }
        .fullScreenCover(isPresented: $toggleEventHistory) {
                NavigationView {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading) {
                            if !eventHistory.isEmpty {
                                ForEach(0..<eventHistory.count, id: \.self) { i in
                                    VStack(alignment: .leading) {
                                        Text(eventHistory[i].eventName)
                                            .font(.headline).bold()
                                            .padding(10)
                                        HStack {
                                            Text("Hours rewarded: \(String(format: "%.1f", eventHistory[i].hoursSpent))")
                                                .font(.caption)
                                            Spacer()
                                            Text("\(eventHistory[i].dateOfService.dateToString(style: "MM/dd/YY"))")
                                                .font(.caption)
                                        }
                                        .padding(10)
                                    }.overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                                    )
                                    .padding(.horizontal)
                                }
                                
                            } else {
                                Text("See your past attended events here")
                            }
                        }
                    }
                .task {
                    FirestoreCRUD().getEventHistory(uid: authVM.decodeUserInfo()!.uid, completion: { eventHistory in
                        self.eventHistory = eventHistory
                    })
                }
                .navigationBarTitle("Event History")
                .navigationBarItems(trailing: CloseButton(isOpen: $toggleEventHistory))
            }
        }
        .fullScreenCover(isPresented: $toggleFullScreenQR) {
            NavigationView {
                Image(uiImage: UIImage(data: generateQRCode(from: (authVM.decodeUserInfo()?.uid)!)!)!)
                    .resizable()
                    .frame(width: 320, height: 320, alignment: .center)
                    .aspectRatio(contentMode: .fit)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                
                
                    .navigationBarTitle("Your QR Code")
                    .navigationBarItems(trailing: CloseButton(isOpen: $toggleFullScreenQR))
            }
        }
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
    
    
    func generateQRCode(from string: String) -> Data? {
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
    
    public func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return path.first
    }
    
    public func documentDirectoryPath() -> UIImage? {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)

        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("exampleJpg.jpg").path)
        }
        return nil
    }
}

struct TopBar: View {
    @EnvironmentObject var authVM: AuthViewModel
    var topEdge: CGFloat
    @Binding var offset: CGFloat
    @Binding var toggleEditInfoSheet: Bool
    var maxHeight: CGFloat
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {

            Image(uiImage: documentDirectoryPath() ?? UIImage())
                .resizable()
                .frame(width: 80, height: 80)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(10)
            
            HStack {
                Text(authVM.decodeUserInfo()?.displayName ?? "John Smith")
                    .font(.largeTitle.bold())
                
                Button(action: {
                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                    hapticResponse.impactOccurred()
                    withAnimation {
                        toggleEditInfoSheet.toggle()
                    }
                }) {
                    Image(systemName: "pencil")
                        .resizable()
                        .foregroundColor(Color.white)
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15, height: 15)
                        .padding(.leading, 10)
                }
            }
            HStack {
            Text(authVM.decodeUserInfo()?.bio ?? "No Bio")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(Color.white.opacity(0.8))
                Spacer(minLength: 20)
            }
        }
        .opacity(Double(getOpacity()))
        .onChange(of: toggleEditInfoSheet) { value in
            if !value {
                authVM.decodeUserInfo()
                documentDirectoryPath()
            }
        }
    }
    
    func getOpacity() -> CGFloat {
        let progress = -offset / 70
        let opacity = 1 - progress
        return offset < 0 ? opacity : 1
    }
    public func documentDirectoryPath() -> UIImage? {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)

        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("exampleJpg.jpg").path)
        }
        return nil
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
