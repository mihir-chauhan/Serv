//
//  HomeView.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

import MapKit
import SDWebImageSwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var results: FirestoreCRUD
    @Environment(\.colorScheme) var colorScheme
    
    @State var toggleHeroAnimation: Bool = false
    @State var showingCategoryDetailAlert = false
    @State var eventDatas = [EventInformationModel]()

    @State var recommendedEvents = [EventInformationModel]()
    @State var allowsTracking: Bool = false
    @State var alertInfoIndex = 0
    @State var totalHours: Double = 0
    
    let defaults = UserDefaults.standard
    var animation: Namespace.ID
    
    var body: some View {
        GeometryReader { geo in

        Group {
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
//                    VStack(alignment: .trailing) {
//                        PVSAProgressBar()
//                        Text("16 more hours to go...")
//                            .font(.caption)
//                    }
                    
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: display.width - 40, height: 50)
                        .foregroundColor(.primary.opacity(0.05))
                        .overlay(
                            HStack {
                                Text("Total hours served")
                                    .bold()
                                Spacer()
                                Text(String(format: "%.2f", totalHours))
                                    .font(.system(size: 25, design: .rounded))
                                    .bold()
                            }.padding(.horizontal)
                        )
                        .padding(.bottom, 5)
                    
                    VStack(alignment: .leading) {
                        Text("Category Filters")
                            .font(.system(.headline))
                            .bold()
                            .padding(.leading, 15)
                        Text("Long press to learn more about a category")
                            .font(.system(.caption))
                            .padding(.leading, 15)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                    ForEach(0..<results.allCategories.count, id: \.self) { index in
                                        Circle()
                                            .frame(width: 75, height: 75)
                                            .foregroundColor(Color(self.defaults.bool(forKey: "\(results.allCategories[index].name)") ? (#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)) : (colorScheme == .dark ?.systemGray4 : .systemGray6)))
                                            .overlay(Text(results.allCategories[index].icon).font(.system(size: 30)))
                                            .onTapGesture() {
                                                results.allCategories[index].savedCategory!.toggle()
                                                DispatchQueue.main.async {
                                                    UserDefaults.standard.setValue(results.allCategories[index].savedCategory!, forKey: "\(results.allCategories[index].name)")
                                                }
                                            }
                                            .onLongPressGesture() {
                                                alertInfoIndex = index
                                                showingCategoryDetailAlert.toggle()
                                            }
                                }.padding(.trailing, 30)
                            }.padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 0))
                        }

                        Spacer().frame(height: 15)
                        if viewModel.allowingLocationTracker {
//                        if(savedCategories.filter{$0}.count != 0) {
//
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    if !recommendedEvents.isEmpty {
                                        ForEach(recommendedEvents, id: \.self) { event in
                                            ForEach(results.allCategories, id: \.self) { i in
                                                if event.category == i.name {
                                                    if self.defaults.bool(forKey: "\(i.name)") && event.time > Date() {
                                                        RecommendedView(data: event, emoji: "\(i.icon)")
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 0))
//
//
//                            }
//
//                            }
//                            else {
//                                Spacer().frame(width: 290, height: 250)
//                            }
                        }
                        else {
                            VStack {
                                Image(systemName: "location.slash.fill")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .aspectRatio(contentMode: .fit)
                                    .symbolRenderingMode(.palette)
                                Text("Please enable location access in Settings")
                                    .bold()
                                    .padding(.horizontal)
                            }.padding()
                                .frame(width: geo.size.width, height: 150)
                        }
                    }
                    
                    
                    Spacer()
                        .padding(.bottom, 90)
                }
                
                
                Spacer()
                    .padding(.bottom, 30)
                
            }
            
        }
        .padding(.vertical)
        }
        .onChange(of: viewModel.queriedEventsList) { value in
            if value.count >= 1 {
                recommendedEvents = value
                print("221, ", recommendedEvents)
            }
        }
        .onAppear {
//            results.queryAllCategories()
            if viewModel.queriedEventsList.count >= 1 {
                recommendedEvents = viewModel.queriedEventsList
                print("228, ", recommendedEvents)
                
            }
        }
        .task {
            viewModel.checkIfLocationServicesIsEnabled(limitResults: true)
            if authViewModel.decodeUserInfo() != nil {
                FirebaseRealtimeDatabaseCRUD().readEvents(for: authViewModel.decodeUserInfo()!.uid) { eventsArray in
                    if eventsArray != nil {
                        for i in 0..<eventsArray!.count {
                            results.getSpecificEvent(eventID: eventsArray![i]) { event in
                                self.eventDatas.append(event)
                                print("FFFF ", eventDatas[0].description)
                            }
                        }
                    }
                }
                
                results.allTimeCompleted(for: authViewModel.decodeUserInfo()!.uid) { totalHours in
                    for i in totalHours {
                        self.totalHours += i
                    }
                }
            }
        }
        
        .alert(isPresented: $showingCategoryDetailAlert) {
            Alert(title: Text(results.allCategories[alertInfoIndex].name), message: Text(results.allCategories[alertInfoIndex].description), dismissButton: .default(Text("Okay")))
        }
        
        if toggleHeroAnimation {
            VStack {
                HomeScheduleDetailView(animation: animation, toggleHeroAnimation: $toggleHeroAnimation, eventDatas: eventDatas)
            }
            .edgesIgnoringSafeArea(.top)
            .padding(.bottom, 100)
        }
    }
    }
}

extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
