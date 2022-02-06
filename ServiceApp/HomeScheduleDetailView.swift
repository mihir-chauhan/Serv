//
//  File.swift
//  ServiceApp
//
//  Created by mimi on 1/2/22.
//
import SwiftUI

struct HomeScheduleDetailView: View {
    @FetchRequest(entity: UserEvent.entity(), sortDescriptors: []) public var fetchedResult: FetchedResults<UserEvent>
    var animation: Namespace.ID
    @Binding var toggleHeroAnimation: Bool
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
                            .offset(y: geo.frame(in: .global).minY/9)
                            
                            .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .matchedGeometryEffect(id: "hero", in: animation)
                                .frame(width: display.width, height: 250)
                                .offset(y: geo.frame(in: .global).minY/9)
                                
                                )
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    toggleHeroAnimation.toggle()
                                }
                            }
                                .overlay(
                                    Image(systemName: "house")
                                        .offset(y: geo.frame(in: .global).minY/9)
                                )
    
                        } else {
                            LinearGradient(gradient: Gradient(colors: [
                                Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 1)),
                                Color.pink
                            ]), startPoint: .topLeading, endPoint: .bottomTrailing)
                            .matchedGeometryEffect(id: "hero", in: animation)
                            .frame(width: display.width, height: 250 + geo.frame(in: .global).minY)
                            .offset(y: -geo.frame(in: .global).minY)
                            .mask(
                            RoundedRectangle(cornerRadius: 20)
                                .matchedGeometryEffect(id: "hero", in: animation)
                                .frame(width: display.width, height: 250 + geo.frame(in: .global).minY)
                                .offset(y: -geo.frame(in: .global).minY)
                                
                                )
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
            
                
                if !self.fetchedResult.isEmpty {

                        ForEach(self.fetchedResult) { event in
                            ScheduleCard(data: EventInformationModel(name: event.name!, host: event.host!, category: event.category!, time: event.time!), onTapCallback: self.cardTapped)
                        }
                    }
                }
                
                
            }
            Spacer()
            
        }
    }
    
    
    
    func cardTapped(data: EventInformationModel) {
        // do something here -- implement later on...
    }
}
