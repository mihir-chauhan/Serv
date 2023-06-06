//
//  HomeView.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var locationVM: LocationTrackerViewModel
    @EnvironmentObject var authVM: AuthViewModel
    @EnvironmentObject var results: FirestoreCRUD
    @Environment(\.colorScheme) var colorScheme
    
    @State var toggleHeroAnimation: Bool = false
    @State var showingCategoryDetailAlert = false
    @State var eventDatas = [EventInformationModel]()
    @State var bookmarkDatas = [EventInformationModel]()
    @State var recommendedEvents = [EventInformationModel]()
    @State var allowsTracking: Bool = false
    @State var alertInfoIndex = 0
    @State var totalHours: Double = 0
    
    
    @State var selectBirthYearSheet: Bool = false
    @State var birthYear: Int = 0
    
    let defaults = UserDefaults.standard
    var animation: Namespace.ID
    
    var body: some View {
        GeometryReader { geo in
            
            Group {
                ZStack {
                    if !toggleHeroAnimation {
                        ScrollView(showsIndicators: false) {
                            VStack(alignment: .leading) {
                                Text("Home")
                                    .font(.largeTitle)
                                    .bold()
                                // Your upcoming events
                                LinearGradient(gradient: Gradient(colors: [
                                    Color("colorPrimary"),
                                    Color("colorSecondary"),
                                    
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
                                        Text("Event Library")
                                            .font(.title2)
                                            .bold()
                                        Text("your upcoming events & bookmarks")
                                            .font(.caption2)
                                        Spacer()
                                        HStack {
                                            Spacer()
                                            Button(action: {
                                                withAnimation(.spring()) {
                                                    toggleHeroAnimation.toggle()
                                                    
                                                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                                    hapticResponse.impactOccurred()
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
                                Text("Browse events")
                                    .font(.system(.headline))
                                    .bold()
                                    .padding(.leading, 15)
                                Text("Tap to toggle | Long press to learn more about a category")
                                    .font(.system(.caption))
                                    .padding(.leading, 15)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack {
                                        ForEach(0..<results.allCategories.count, id: \.self) { index in
                                            Circle()
                                                .frame(width: 75, height: 75)
                                                .foregroundColor(Color(self.defaults.bool(forKey: "\(results.allCategories[index].name)") ? (#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4))
                                                                       
                                                                       : (colorScheme == .dark ?.systemGray4 : .systemGray6)))
                                                .overlay(Text(results.allCategories[index].icon).font(.system(size: 30)))
                                                .onTapGesture() {
                                                    withAnimation {
                                                        results.allCategories[index].savedCategory!.toggle()
                                                    }
                                                    UserDefaults.standard.setValue(results.allCategories[index].savedCategory!, forKey: "\(results.allCategories[index].name)")
                                                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                                    hapticResponse.impactOccurred()
                                                    
                                                }
                                                .onLongPressGesture() {
                                                    alertInfoIndex = index
                                                    showingCategoryDetailAlert.toggle()
                                                    let hapticResponse = UIImpactFeedbackGenerator(style: .heavy)
                                                    hapticResponse.impactOccurred()
                                                }
                                        }.padding(.trailing, 20)
                                    }.padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
                                }
                                
                                Spacer().frame(height: 15)
                                if locationVM.allowingLocationTracker {
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack {
                                            if !recommendedEvents.isEmpty {
                                                ForEach(recommendedEvents, id: \.self) { event in
                                                    ForEach(results.allCategories, id: \.self) { i in
                                                        if event.category == i.name {
                                                            if self.defaults.bool(forKey: i.name) && event.time > Date() {
                                                                RecommendedView(data: event, emoji: i.icon)
                                                            }
                                                        }
                                                    }
                                                }
                                            }
                                        }.padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 0))
                                    }
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
            .onChange(of: locationVM.queriedEventsList) { value in
                if value.count >= 1 {
                    recommendedEvents = value
                }
            }
            .onAppear {
                if locationVM.queriedEventsList.count >= 1 {
                    recommendedEvents = locationVM.queriedEventsList
                }
            }
            .task {
                locationVM.checkIfLocationServicesIsEnabled(limitResults: true)
                
                print("Before: newAGUser?", UserDefaults.standard.bool(forKey: "newAppleGoogleUser"))
                if UserDefaults.standard.bool(forKey: "newAppleGoogleUser") {
                    UserDefaults.standard.set(false, forKey: "newAppleGoogleUser")
                    self.selectBirthYearSheet.toggle()
                }
                print("After: newAGUser?", UserDefaults.standard.bool(forKey: "newAppleGoogleUser"))
                if authVM.decodeUserInfo() != nil {
                    results.allTimeCompleted(for: authVM.decodeUserInfo()!.uid) { totalHours in
                        for i in totalHours {
                            self.totalHours += i
                        }
                    }
                    if(results.allCategories.count != 0) {
                        FirebaseRealtimeDatabaseCRUD().readEvents(for: authVM.decodeUserInfo()!.uid) { eventsArray in
                            if eventsArray != nil {
                                for i in 0..<eventsArray!.count {
                                    results.getSpecificEvent(eventID: eventsArray![i]) { event in
                                        if event.time > Date().startOfDay {
                                            self.eventDatas.append(event)
                                        }
                                    }
                                }
                            }
                        }
                        
                        FirebaseRealtimeDatabaseCRUD().readBookmarks(for: authVM.decodeUserInfo()!.uid) { bookmarkArray in
                            if bookmarkArray != nil {
                                for i in 0..<bookmarkArray!.count {
                                    results.getSpecificEvent(eventID: bookmarkArray![i]) { event in
                                        if event.time > Date().startOfDay {
                                            self.bookmarkDatas.append(event)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        results.queryAllCategoriesClosure(resetAllToTrue: false) { result in
                            FirebaseRealtimeDatabaseCRUD().readEvents(for: authVM.decodeUserInfo()!.uid) { eventsArray in
                                if eventsArray != nil {
                                    for i in 0..<eventsArray!.count {
                                        results.getSpecificEvent(eventID: eventsArray![i]) { event in
                                            if event.time > Date().startOfDay {
                                                self.eventDatas.append(event)
                                            }
                                        }
                                    }
                                }
                            }
                            
                            FirebaseRealtimeDatabaseCRUD().readBookmarks(for: authVM.decodeUserInfo()!.uid) { bookmarkArray in
                                if bookmarkArray != nil {
                                    for i in 0..<bookmarkArray!.count {
                                        results.getSpecificEvent(eventID: bookmarkArray![i]) { event in
                                            if event.time > Date().startOfDay {
                                                self.bookmarkDatas.append(event)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            .alert(isPresented: $showingCategoryDetailAlert) {
                Alert(title: Text(results.allCategories[alertInfoIndex].name), message: Text(results.allCategories[alertInfoIndex].description), dismissButton: .default(Text("Okay")))
            }
            .sheet(isPresented: $selectBirthYearSheet, onDismiss: {
                if let data = authVM.decodeUserInfo() {
                    FirebaseRealtimeDatabaseCRUD().setBirthYear(uid: data.uid, birthYear: birthYear)
                    authVM.encodeUserInfo(for: UserInfoFromAuth(uid: data.uid, displayName: data.displayName, photoURL: data.photoURL, email: data.email, bio: data.bio, birthYear: birthYear))
                    print("setBirthYear", birthYear)
                } else {
                    print("FAILED TO SET birthYear", birthYear)
                }
            }, content: {
                AgeVerification(showView: $selectBirthYearSheet, code: $birthYear, dismissDisabled: true)
            })
            
            
            if toggleHeroAnimation {
                GeometryReader { proxy in
                    let topEdge = proxy.safeAreaInsets.top
                    HomeScheduleDetailView(animation: animation, toggleHeroAnimation: $toggleHeroAnimation, eventDatas: eventDatas, bookmarkDatas: bookmarkDatas, topEdge: topEdge)
                }
                .edgesIgnoringSafeArea(.top)
                .padding(.bottom, 100)
            }
        }
    }
}

