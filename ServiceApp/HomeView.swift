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
    var animation: Namespace.ID
    @State var toggleHeroAnimation: Bool = false
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    @ObservedObject var results = FirestoreCRUD()
    @State var showingCategoryDetailAlert = false
    
    @State var firstFiveElements = [EventInformationModel]()
    @State var eventDatas = [EventInformationModel]()
    
    @Environment(\.colorScheme) var colorScheme

    var categories = ["🌲", "🤝🏿", "🏫", "👨‍⚕️", "🐶"]
    var categoryTitles = ["Environmental", "Humanitarian", "Education", "Health", "Wildlife"]
    var categoryDescriptions = ["Environmental projects may have volunteers working in an office preparing educational materials, outside creating trails (or recycling, or picking up trash, or planting and tending flora), or in schools or neighborhood centers providing community outreach.", "Humanitarian service programs usually focus on servies such as feeding low income families or having different types of clothing, food, or other drives in which you can help donate resources to ones that are in need of them. Most of the time volunteers will work to either collect these resources or help in the distribution at various places.", "Educational programs range from lending a hand at an elementary school to teaching English to adults in order to improve their job opportunities. Volunteers might provide vocational training or health and hygiene education through workshops, or tutor struggling students at an after-school program.", "While opportunities abound for specialized skills, from first-aid training to heart surgery, you don’t necessarily need to be a medical professional to assist in a community health clinic or public hospital. Volunteers may be able to help organize workshops, assist medical staff, provide translation skills, or raise awareness on issues such as HIV/AIDS.", "Volunteers can do activities such as protecting turtle hatchlings on their journey from nest to sea, supporting the rehabilitation of injured and trafficked animals, or restoring natural habitats for endangered species. Not all wildlife protection projects allow volunteers to work with their animals; work may instead be focused on the cleaning of cages, restoration of natural habitats, or visual monitoring of animal activity in the wild."]
    @State var alertInfoIndex = 0
    
    
    @State var selectedIndexOfServiceType = [false, false, false, false, false]

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
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                if firstFiveElements.isEmpty {
                                    Text("No recommended events!")
                                } else {
                                    ForEach(firstFiveElements, id: \.self) { event in
                                        RecommendedView(data: event)
                                    }
                                }
                                
                            }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 0))
                            
                        }
                    }
                }
                
                
                Spacer()
                    .padding(.bottom, 30)
                
            }
            
        }
        .padding(.vertical)
        
        .onChange(of: viewModel.queriedEventsList) { value in
            if value.count > 3 {
                firstFiveElements = Array(value[0...3])
            }
            print(value)
        }
        .task {
            viewModel.checkIfLocationServicesIsEnabled()

            FirebaseRealtimeDatabaseCRUD().readEvents(for: user_uuid!) { eventsArray in
                if eventsArray != nil {
                    for i in 0..<eventsArray!.count {
                        for x in 0..<results.allFIRResults.count {
                            print("akjdsnflasdjnflasdjnf: ", results.allFIRResults[x].FIRDocID!, eventsArray![i])
                            if results.allFIRResults[x].FIRDocID! == eventsArray![i] {
                                self.eventDatas.append(results.allFIRResults[x])
                                print("akjdsnflasdjnfadfadfkajnsdfjkasndfkajsndfjlasdjnf: ", self.eventDatas.count, self.eventDatas)
                            }
                        }
                    }
                }
            }
            
            
        }
        
        
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

