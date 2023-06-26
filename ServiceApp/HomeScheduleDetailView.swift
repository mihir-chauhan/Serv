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
    @State var bookmarkDatas = [EventInformationModel]()
    
    @State var pickerSelection = 0
    var currentlyPresenting: EventInformationModel = EventInformationModel()
    
    @State var showDetailView = false
    
    let maxHeight = display.height / 3.1
    var topEdge: CGFloat
    
    @State var offset: CGFloat = 0
    
    var body: some View {
        if toggleHeroAnimation {
            if showDetailView {
                ScheduleCardDetailView(show: $showDetailView, toggleHeroAnimation: $toggleHeroAnimation)
            } else {
                ScrollView {
                    VStack {
                        GeometryReader { geo in
                            Sticky(pickerSelection: $pickerSelection, topEdge: topEdge, offset: $offset, toggleHeroAnimation: $toggleHeroAnimation, maxHeight: maxHeight)
                                .cornerRadius(20, corners: .allCorners)
                                .matchedGeometryEffect(id: "hero", in: animation)
                                .offset(y: -geo.frame(in: .global).minY)
                                .padding()
                                .foregroundColor(.white)
                                .frame(width: UIScreen.main.bounds.width, height: getHeaderHeight(), alignment: .bottom)
                                .background(
                                    LinearGradient(gradient: Gradient(colors: [
                                        Color("colorPrimary"),
                                        Color("colorSecondary"),
                                        
                                        
                                    ]), startPoint: .topLeading, endPoint: .bottomTrailing),
                                    in: CustomCorner(corners: [.bottomLeft, .bottomRight], radius: getCornerRadius()))
                        }
                        .overlay(
                            HStack {
                                Picker("Picker", selection: $pickerSelection) {
                                    Text("Upcoming").bold().tag(0)
                                    Text("Bookmarked").bold().tag(1)
                                }
                                .pickerStyle(.segmented)
                                .opacity(Double(topBarTitleOpacity()))
                            }
                                .padding()
                                .frame(height: 60)
                                .foregroundColor(.white)
                                .padding(.top, topEdge + 35)
                            , alignment: .top
                        )
                        .frame(height: maxHeight)
                        .offset(y: -offset)
                        .zIndex(1)
                        VStack {
                            switch pickerSelection {
                            case 1:
                                ForEach(bookmarkDatas, id: \.id) { event in
                                    BookmarkCard(animation: animation, data: event, onDelete: {
                                        for (index, loopEvent) in bookmarkDatas.enumerated() {
                                            if(loopEvent.id == event.id) {
                                                print("index", index)
                                                bookmarkDatas.remove(at: index)
                                            }
                                        }
                                    }, show: $showDetailView)
                                }
                                if bookmarkDatas.isEmpty {
                                    Text("No bookmarked events").bold().font(.title3).padding()
                                }
                            default:
                                ForEach(eventDatas, id: \.id) { event in
                                    ScheduleCard(animation: animation, data: event, onDelete: {
                                        for (index, loopEvent) in eventDatas.enumerated() {
                                            if(loopEvent.id == event.id) {
                                                print("index", index)
                                                eventDatas.remove(at: index)
                                            }
                                        }
                                    }, show: $showDetailView)
                                }
                                if eventDatas.isEmpty {
                                    Text("No events signed up yet!").bold().font(.title3).padding()
                                }
                            }
                        }
                    }
                    .modifier(OffsetModifier(offset: $offset))
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
        }
    }
    
    func getHeaderHeight() -> CGFloat {
        let topHeight = maxHeight + offset
        return topHeight > (80 + topEdge)  ? topHeight : (100 + topEdge)
    }
    func getCornerRadius() -> CGFloat {
        let progress = -offset / (maxHeight - (100 + topEdge))
        
        let value = 1 - progress
        
        let radius = value * 20
        
        return offset < 0 ? radius : 20
    }
    func topBarTitleOpacity() -> CGFloat {
        let progress = -(offset + 70) / (maxHeight - (80 + topEdge))
        
        let opacity = 1 - progress
        
        return 1 - opacity
    }
    
}

struct Sticky: View {
    @Binding var pickerSelection: Int
    var topEdge: CGFloat
    @Binding var offset: CGFloat
    @Binding var toggleHeroAnimation: Bool
    var maxHeight: CGFloat
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            HStack {
                Text("Your Event Library")
                    .font(.title.bold())
                CloseButton(isOpen: $toggleHeroAnimation, color: Color(#colorLiteral(red: 0.6823841333, green: 0.6823301315, blue: 0.6980193257, alpha: 1)))
                
            }
            .padding(.leading, 15)
            .padding(.top, topEdge + 35)
            Spacer()
            Picker("Picker", selection: $pickerSelection) {
                Text("Upcoming").bold().tag(0)
                Text("Bookmarked").bold().tag(1)
            }
            .pickerStyle(.segmented)
            
        }
        .opacity(Double(getOpacity()))
        
    }
    func getOpacity() -> CGFloat {
        let progress = -offset / 99
        let opacity = 1 - progress
        return offset < 0 ? opacity : 1
    }
}
