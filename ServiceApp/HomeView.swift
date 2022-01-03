//
//  HomeView.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

import SwiftUI

struct HomeView: View {
    var animation: Namespace.ID
    @State var toggleHeroAnimation: Bool = false
    var body: some View {
        ZStack {
            if !toggleHeroAnimation {
            ScrollView {
                VStack(alignment: .trailing) {
                    PVSAProgressBar()
                    Text("46 more hours to go...")
                        .font(.caption)
                }
                //                Your upcoming events
                RoundedRectangle(cornerRadius: 20)
                    
                    .matchedGeometryEffect(id: "hero", in: animation)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 125)
                    .foregroundColor(Color(.systemGray4))
                    .overlay(
                        Image(systemName: "house")
                    )
                    
                    .onTapGesture {
                        withAnimation(.spring()) {
                            toggleHeroAnimation.toggle()
                        }
                    }
                VStack(alignment: .leading) {
                    Text("Categories")
                        .font(.system(.headline))
                        .padding(.leading, 30)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<5, id: \.self) { _ in
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 75, height: 75)
                                    .foregroundColor(Color(.systemGray4))
                                    .overlay(Text("🌲").font(.system(size: 30)))
                            }.padding(.leading, 30)
                        }
                    }
                    
                    Text("Recommended")
                        .font(.system(.headline))
                        .padding(.leading, 30)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<3, id: \.self) { _ in
                                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 180, height: 250)
                                        .foregroundColor(Color(#colorLiteral(red: 0.9688304554, green: 0.9519491526, blue: 0.8814709677, alpha: 1)))
                                    RoundedRectangle(cornerRadius: 20)
                                        .frame(width: 180, height: 145)
                                        .foregroundColor(Color(.systemGray4))
                                }
                                
                            }.padding(.leading, 30)
                        }
                    }
                    Text("Friend Activity")
                        .font(.system(.headline))
                        .padding(.leading, 30)
                }
                
                
                Spacer()
                
            }.padding(.vertical)
        }
            if toggleHeroAnimation {
                VStack {
                    HomeScheduleDetailView(animation: animation, toggleHeroAnimation: $toggleHeroAnimation)
                        
                
                }
                .edgesIgnoringSafeArea(.top)
                .padding(.bottom, 100)
            }
    }
    }
}

