//
//  CustomTabBar.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import FirebaseAuth

struct CustomTabBar: View {
    @State public var selectedIndex: TabBarItem = .account
    @Namespace var animation
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
                switch selectedIndex {
                case .home:
                    HomeView(animation: animation)
                case .schedule:
                    Schedule()
                case .plus:
                    MapView()
                case .socials:
                    Socials()
                case .account:
                    GeometryReader {proxy in
                        let topEdge = proxy.safeAreaInsets.top
                        
                        Account(topEdge: topEdge)
                            .ignoresSafeArea(.all, edges: .top)
                    }
                }
        
            HStack() {
                ForEach(TabBarItem.allCases, id: \.self) { icon in
                    Spacer()
                    Button(action: {
                        withAnimation {
                        self.selectedIndex = icon
                        }
                    }) {
                        if icon == .plus {
                            Image(systemName: "plus")
                                .font(.system(size: 25))
                                .foregroundColor(.white)
                                .rotationEffect(Angle(degrees: self.selectedIndex == icon ? 45 : 0))
                                .frame(width: 55, height: 55)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
                        else {
                            Image(systemName: icon.icon)
                                .font(.system(size: 25))
                                .foregroundColor(self.selectedIndex == icon ? .blue : Color(UIColor.gray))
                                
                        }
                    }
                    Spacer()
                }
            }.padding(.top, 10)
                .padding(.bottom, 30)
                .background(CustomMaterialEffectBlur())
        }
        .ignoresSafeArea(.keyboard)
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct CustomMaterialEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}

enum TabBarItem: Int, CaseIterable {
    case home = 0
    case schedule
    case plus
    case socials
    case account
    
    var icon: String {
        switch self {
            case .home: return "house"
            case .schedule: return "calendar"
            case .plus: return "plus"
            case .socials: return "globe"
            case .account: return "person"
        
        }
    }
    
    var title: String {
        switch self {
            case .home: return "Home"
            case .schedule: return "Schedule"
            case .plus: return "Discover"
            case .socials: return "Social"
            case .account: return "Account"
        }
    }
}
