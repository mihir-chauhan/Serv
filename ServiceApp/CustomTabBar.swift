//
//  CustomTabBar.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import FirebaseAuth

struct CustomTabBar: View {
    @EnvironmentObject private var tabBarController: TabBarController
    @Namespace var animation
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
            switch tabBarController.selectedIndex {
            case .home:
                HomeView(animation: animation)
            case .map:
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
                            self.tabBarController.selectedIndex = icon
                            let haptic = UIImpactFeedbackGenerator(style: .soft)
                            haptic.impactOccurred()
                        }
                    }) {
                        Image(systemName: self.tabBarController.selectedIndex == icon ? icon.icon + ".fill" : icon.icon)
                            .font(.system(size: 25))
                            .foregroundColor(self.tabBarController.selectedIndex == icon ? .blue : Color(UIColor.gray))
                            .frame(width: 55, height: 55)
                            .cornerRadius(30)
                        
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

enum TabBarItem: Int, CaseIterable {
    case home = 0
    case map
    case socials
    case account
    
    var icon: String {
        switch self {
        case .home: return "house"
        case .map: return "map"
        case .socials: return "person.2.wave.2"
        case .account: return "gearshape"
            
        }
    }
    
    var title: String {
        switch self {
        case .home: return "Home"
        case .map: return "Discover"
        case .socials: return "Social"
        case .account: return "Account"
        }
    }
}
