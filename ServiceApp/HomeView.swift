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
    var animation: Namespace.ID
    @State var toggleHeroAnimation: Bool = false
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    @ObservedObject var results = FirestoreCRUD()
    @State var showingCategoryDetailAlert = false
    
    @State var recommendedEvents = [EventInformationModel]()
    @State var eventDatas = [EventInformationModel]()
    
    @State var numberOfShownRecommendations = 0
    
    @State var allowsTracking: Bool = false
    @Environment(\.colorScheme) var colorScheme

    var categories = ["🌲", "🤝🏿", "🏫", "👨‍⚕️", "🐶"]
    var categoryTitles = ["Environmental", "Humanitarian", "Education", "Health", "Wildlife"]
    var categoryDescriptions = ["Environmental projects may have volunteers working in an office preparing educational materials, outside creating trails (or recycling, or picking up trash, or planting and tending flora), or in schools or neighborhood centers providing community outreach.", "Humanitarian service programs usually focus on servies such as feeding low income families or having different types of clothing, food, or other drives in which you can help donate resources to ones that are in need of them. Most of the time volunteers will work to either collect these resources or help in the distribution at various places.", "Educational programs range from lending a hand at an elementary school to teaching English to adults in order to improve their job opportunities. Volunteers might provide vocational training or health and hygiene education through workshops, or tutor struggling students at an after-school program.", "While opportunities abound for specialized skills, from first-aid training to heart surgery, you don’t necessarily need to be a medical professional to assist in a community health clinic or public hospital. Volunteers may be able to help organize workshops, assist medical staff, provide translation skills, or raise awareness on issues such as HIV/AIDS.", "Volunteers can do activities such as protecting turtle hatchlings on their journey from nest to sea, supporting the rehabilitation of injured and trafficked animals, or restoring natural habitats for endangered species. Not all wildlife protection projects allow volunteers to work with their animals; work may instead be focused on the cleaning of cages, restoration of natural habitats, or visual monitoring of animal activity in the wild."]
    @State var alertInfoIndex = 0
    
    
    @State var selectedIndexOfServiceType = [true, false, false, false, false]

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
                    
                    VStack(alignment: .leading) {
                        Text("Category Filters")
                            .font(.system(.headline))
                            .padding(.leading, 15)
                        Text("Long press to learn more about a category")
                            .font(.system(.caption))
                            .padding(.leading, 15)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<5, id: \.self) { index in
                                    RoundedRectangle(cornerRadius: 50)
                                        .frame(width: 75, height: 75)
                                        .foregroundColor(Color(selectedIndexOfServiceType[index] ? (#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)) : (colorScheme == .dark ?.systemGray4 : .systemGray6)))
                                        .overlay(Text(categories[index]).font(.system(size: 30)))
                                        .onTapGesture() {
                                            selectedIndexOfServiceType[index] = !selectedIndexOfServiceType[index]
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
                        if(selectedIndexOfServiceType.filter{$0}.count != 0) {
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    if !recommendedEvents.isEmpty {
                                        ForEach(recommendedEvents, id: \.self) { event in
                                            // TODO: i dont like that i have to match environmental to idnex 0 maybe use dict later on
                                            if((event.category == "Environmental" && selectedIndexOfServiceType[0]) ||
                                               (event.category == "Humanitarian" && selectedIndexOfServiceType[1]) ||
                                               (event.category == "Educational" && selectedIndexOfServiceType[2]) ||
                                               (event.category == "Health" && selectedIndexOfServiceType[3]) ||
                                               (event.category == "Wildlife" && selectedIndexOfServiceType[4])) {
                                                RecommendedView(data: event)
                                                let _ = print(recommendedEvents)
                                            }
                                        }
                                    }
                                }
                                
                                
                            }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 0))
                                
                            }
                            else {
                                Spacer().frame(width: 290, height: 250)
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
                                
                                Button(action: {
//                                    allowsTracking = true
//                                    viewModel.checkIfLocationServicesIsEnabled()
                                }) {
                                    Capsule()
                                        .frame(width: 160, height: 35)
                                        .foregroundColor(.blue.opacity(0.05))
                                        .overlay(
                                            Text("DEBUG PURPOSES")
                                                .foregroundColor(.blue)
                                        )
                                }.padding()
                            }.padding()
                                .frame(width: geo.size.width, height: 150)
                        }
                    }
                }
                
                
                Spacer()
                    .padding(.bottom, 30)
                
            }
            
        }
        .padding(.vertical)
        }
        .onChange(of: viewModel.queriedEventsList) { value in
                    if value.count > 3 {
                        recommendedEvents = value
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
                            }
                        }
                    }
                }
            }
            
        }
//        .onChange(of: viewModel.allowingLocationTracker) { _ in
//            viewModel.checkIfLocationServicesIsEnabled()
//
//        }
        
        
        .alert(isPresented: $showingCategoryDetailAlert) {
            Alert(title: Text(categoryTitles[alertInfoIndex]), message: Text(categoryDescriptions[alertInfoIndex]), dismissButton: .default(Text("Okay")))
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

