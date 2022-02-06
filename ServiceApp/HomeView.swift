//
//  HomeView.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    var animation: Namespace.ID
    @State var toggleHeroAnimation: Bool = false
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    @ObservedObject var results = FirestoreCRUD()
    
    var categories = ["🌲", "🤝🏿", "🏫", "👨‍⚕️", "🐶"]
    
    var body: some View {
        ZStack {
            if !toggleHeroAnimation {
                ScrollView {
                    VStack(alignment: .leading) {
                        Text("Home")
                            .font(.largeTitle)
                            .bold()
                        //                Your upcoming events
                        LinearGradient(gradient: Gradient(colors: [
                            Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 1)),
                            Color.pink
                        ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .matchedGeometryEffect(id: "hero", in: animation)
                            .frame(width: display.width - 40, height: 125)
                            .mask(
                                RoundedRectangle(cornerRadius: 20)
                                
                                    .matchedGeometryEffect(id: "hero", in: animation)
                                    .frame(width: display.width - 40, height: 125)
                                    .foregroundColor(Color(.systemGray4))
                                
                            )
                            .overlay(
                                VStack(alignment: .leading) {
                                    Text("Your Upcoming Events")
                                        .font(.title2)
                                        .bold()
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        Button(action: {
                                            withAnimation(.spring()) {
                                                toggleHeroAnimation.toggle()
                                            }
                                        }) {
                                            ZStack {
                                                CustomMaterialEffectBlur(blurStyle: .systemMaterial)
                                                    .mask(
                                                        Circle()
                                                    )
                                                    .frame(width: 60, height: 60)
                                                    .overlay(
                                                        Image(systemName: "arrow.right")
                                                            .renderingMode(.original)
                                                            .resizable()
                                                            .aspectRatio(contentMode: .fit)
                                                            .frame(width: 25, height: 25)
                                                    )
                                            }
                                            
                                        }
                                    }
                                }.padding(15)
                            )
                    }
                    VStack(alignment: .trailing) {
                        PVSAProgressBar()
                        Text("16 more hours to go...")
                            .font(.caption)
                    }
                    VStack(alignment: .leading) {
                        Text("Categories")
                            .font(.system(.headline))
                            .padding(.leading, 30)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 50)
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(Color(.systemGray4))
                                        .overlay(Text(categories[index]).font(.system(size: 30)))
                                }.padding(.trailing, 30)
                            }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                        }
                        
                        Text("Recommended")
                            .font(.system(.headline))
                            .padding(.leading, 30)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                //                            TODO: create a detail view for the cards listed in "recommended"
                                ForEach(0..<self.results.allFIRResults.count, id: \.self) { img in
                                    RecommendedView(data: results.allFIRResults[img]).padding(.trailing, 30)
                                }

                            }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 0))
                            
                        }
                    }
//                    Text("Friend Activity")
//                        .font(.system(.headline))
//                        .padding(.leading, 30)
                }
                
                
                Spacer()
                    .padding(.bottom, 30)
                
            }
        }.padding(.vertical)
        if toggleHeroAnimation {
            VStack {
                HomeScheduleDetailView(animation: animation, toggleHeroAnimation: $toggleHeroAnimation)
                
            }
            .edgesIgnoringSafeArea(.top)
            .padding(.bottom, 100)
        }
    }
}

