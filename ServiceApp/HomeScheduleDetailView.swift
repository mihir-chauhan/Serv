//
//  File.swift
//  ServiceApp
//
//  Created by mimi on 1/2/22.
//
import SwiftUI

struct HomeScheduleDetailView: View {
    var animation: Namespace.ID
    @Binding var toggleHeroAnimation: Bool    
    var eventDatas = [EventInformationModel]()
    
    var body: some View {
        if toggleHeroAnimation {
            ScrollView {
                VStack {
                    GeometryReader { geo in
                        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                            if geo.frame(in: .global).minY <= 0 {
                                LinearGradient(gradient: Gradient(colors: [
                                    Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 1)),
                                    Color.pink
                                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                                .matchedGeometryEffect(id: "hero", in: animation)
                                .frame(width: display.width, height: 250)
                                .cornerRadius(25, corners: .allCorners)
                                    .offset(y: geo.frame(in: .global).minY/9)
                                    .onTapGesture {
                                        withAnimation(.spring()) {
                                            toggleHeroAnimation.toggle()
                                            
                                            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                            hapticResponse.impactOccurred()
                                        }
                                    }
                                
                                
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
                                            .offset(y: geo.frame(in: .global).minY/9)
                                    )
                                
                            } else {
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
                                        }
                                    }
                                    .overlay(
                                        Text("Your Upcoming Events")
                                            .offset(y: -geo.frame(in: .global).minY)
                                    )
                            }
                        }
                    }.frame(height: 250)
                    
                    
                    
                    ForEach(0..<eventDatas.count) { event in
                        ScheduleCard(data: eventDatas[event], onTapCallback: self.cardTapped)
                    }
                }
                
                
            }
            Spacer()
            
            
        }
    }
    
    
    
    func cardTapped(data: EventInformationModel) {
        //        let url = URL(string: "maps://?saddr=&daddr=\(data.coordinate.latitude),\(data.coordinate.longitude)")
        //        if UIApplication.shared.canOpenURL(url!) {
        //              UIApplication.shared.open(url!, options: [:], completionHandler: nil)
        //        }
        
    }
}
