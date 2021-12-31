//
//  CustomTabBar.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct CustomTabBar: View {
    @State private var selectedIndex: TabBarItem = .plus
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .bottom)) {
//            Color.gray
//        VStack {
//            ZStack {
                switch selectedIndex {
                case .home:
                    HomeView()
                case .schedule:
                    HomeView()
                case .plus:
                    MapView1()
                case .socials:
                    Socials()
                case .account:
                    Account()
                }
        
            HStack(spacing: 0) {
                ForEach(TabBarItem.allCases, id: \.self) { icon in
                    Spacer()
                    Button(action: {
                        self.selectedIndex = icon
                    }) {
                        if icon == .plus {
                            Image(systemName: "plus")
                                .font(.system(size: 25))
                                .foregroundColor(.white)

                                .frame(width: 55, height: 55)
                                .background(Color.blue)
                                .cornerRadius(30)
                        }
                        else {
                        Image(systemName: icon.icon)
                            .font(.system(size: 25))
                            .foregroundColor(self.selectedIndex == icon ? .black : Color(UIColor.lightGray))
                        }
                    }
                    Spacer()
                }
                
//                .edgesIgnoringSafeArea(.bottom)
//                .padding(.bottom, UIScreen.main.bounds.minY + 10)
            }
//            .background(Color.white.opacity(1))
            
//    .background(CustomMaterialEffectBlur())
            
        }
        
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
