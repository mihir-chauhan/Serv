//
//  File.swift
//  ServiceApp
//
//  Created by mimi on 1/2/22.
//
import SwiftUI

struct HomeScheduleDetailView: View {
    @Namespace private var namespace
    var animation: Namespace.ID
    @Binding var toggleHeroAnimation: Bool
    @State var eventDatas = [EventInformationModel]()
    
    var currentlyPresenting: EventInformationModel = EventInformationModel()
    
    @State var show = false
    var body: some View {
        if toggleHeroAnimation {
            if show {
                ScheduleCardDetailView(show: $show, toggleHeroAnimation: $toggleHeroAnimation)
            } else {
                ScrollView {
                    VStack {
                        GeometryReader { geo in
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                LinearGradient(gradient: Gradient(colors: [
                                    Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 1)),
                                    Color.pink
                                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .cornerRadius(20, corners: .allCorners)
                                .matchedGeometryEffect(id: "hero", in: animation)
                                .frame(width: UIScreen.main.bounds.width, height: 250 + geo.frame(in: .global).minY)
                                .foregroundColor(Color(.systemGray4))
                                .offset(y: -geo.frame(in: .global).minY)
                                
                                .onTapGesture {
                                    withAnimation(.spring()) {
                                        toggleHeroAnimation.toggle()
                                        
                                        let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                        hapticResponse.impactOccurred()
                                    }
                                }
                                .overlay(
                                    CustomMaterialEffectBlur(blurStyle: .systemMaterial)
                                        .mask( Circle() )
                                        .frame(width: 60, height: 60)
                                        .cornerRadius(20, corners: .allCorners)
                                        .overlay(
                                            Image(systemName: "house")
                                                .renderingMode(.original)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 25, height: 25)
                                        )
                                        .offset(y: -geo.frame(in: .global).minY)
                                        .onTapGesture {
                                            withAnimation(.spring()) {
                                                toggleHeroAnimation.toggle()
                                                
                                                let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                                hapticResponse.impactOccurred()
                                            }
                                        }
                                )
                            }
                        }.frame(height: 250)
                        
                        
                        
                        ForEach(0..<eventDatas.count) { event in
                            ScheduleCard(animation: animation, data: eventDatas[event], show: $show)
                        }
                    }
                    
                    
                }
            }
            Spacer()
            
            
        }
    }
}
