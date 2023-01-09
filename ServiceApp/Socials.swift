//
//  Socials.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct Socials: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showingSheet = false
    @State private var showingFriendDetailSheet = false
    @State private var nameForDetailSheet = ""
    @State private var imgForDetailSheet = URL(string: "https://icon-library.com/images/generic-profile-icon/generic-profile-icon-23.jpg")!
    @State var sheetMode: SheetMode = .quarter
    
    @State var listOfFriends = [UserInfoFromAuth]()
    @State var listOfEventsFriendIsGoing: [EventInformationModel] = []
    
    @State var haveFriends: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {

                if self.listOfFriends.isEmpty {
                    LeaderboardView(listOfFriends: [])
                        .padding(.bottom, 50)
                        .overlay(
                            haveFriends ? nil : CustomMaterialEffectBlur(blurStyle: .systemUltraThinMaterial).cornerRadius(25).offset(y: -10).overlay(Text("Leaderboard would appear after you add friends").font(.headline).bold().padding())
                        )
                    Text("No friends to show!").font(.title).bold()
                        .offset(y: UIScreen.main.bounds.height / 5)
                    
                } else {
                    let sorted = self.listOfFriends.sorted {
                        let sum1 = $0.hoursSpent.reduce(0, +)
                        let sum2 = $1.hoursSpent.reduce(0, +)
                        return sum1 > sum2
                    }
                    let _ = print("ALL MY FRIENDS", sorted)
                    LeaderboardView(listOfFriends: sorted)
                        .padding(.bottom, 50)
                        .overlay(
                            haveFriends ? nil : CustomMaterialEffectBlur(blurStyle: .systemUltraThinMaterial).cornerRadius(25).offset(y: -10).overlay(Text("Leaderboard would appear after you add friends").font(.headline).bold().padding())
                        )
                    
                    ForEach(sorted, id: \.self) { friend in
                        
                        FriendCardView(data: friend, listOfEventsFriendIsGoing: listOfEventsFriendIsGoing)
//                            .sheet(isPresented: $showingFriendDetailSheet) {
//                                let _ = print("FRIEND INFO SHOWING:", friend.displayName)
//                                FriendDetailSheet(data: friend)
//                            }
                    }.padding(.horizontal)
                }
            }
            .navigationTitle("Socials")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        let haptic = UIImpactFeedbackGenerator(style: .soft)
                        haptic.impactOccurred()
                        showingSheet.toggle()
                    }) {
                        Image(systemName: "link.badge.plus")
                            .renderingMode(.original)
                    }
                    .sheet(isPresented: $showingSheet) {
                        AddFriendSheet()
                    }
                    
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        let haptic = UIImpactFeedbackGenerator(style: .soft)
                        haptic.impactOccurred()
                        FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { allFriends in
                            self.listOfFriends.removeAll()
                            for friend in allFriends {
                                if !allFriends.isEmpty { haveFriends = true }
                                FirebaseRealtimeDatabaseCRUD().getUserFriendInfo(uid: friend) { friendInfo in
                                    self.listOfFriends.append(friendInfo)
                                }
                            }
                            self.listOfFriends.sort {
                                let sum1 = $0.hoursSpent.reduce(0, +)
                                let sum2 = $1.hoursSpent.reduce(0, +)
                                return sum1 > sum2
                            }
                            print(self.listOfFriends, "IS SORTED??!!")
                            
                        }
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .renderingMode(.original)
                    }
                    
                }
            }
            
        }
        .task {
            //        TODO: when querying from Firestore, make sure to sort based on PVSA hours (greatest to least)
            FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { allFriends in
                self.listOfFriends.removeAll()
                if !allFriends.isEmpty { haveFriends = true }
                for friend in allFriends {
                    FirebaseRealtimeDatabaseCRUD().getUserFriendInfo(uid: friend) { friendInfo in
                        
                        self.listOfFriends.append(friendInfo)
                    }
                    
                    
                }
                // problem is blockinggg
                print("ALL MY FRIENDS", listOfFriends.count)
                for friend in listOfFriends {
                    print("!!!uuid:", friend.uid!)
                    FriendEventsInCommon().singularFriendEventRecognizer(uidFriend: friend.uid) { events in
                        print("Events Count", events.count)
                        for event in events {
                            FirestoreCRUD().getSpecificEvent(eventID: event) { eventName in
                                self.listOfEventsFriendIsGoing.append(eventName)
                                print("Events", eventName)
                            }
                        }
                    }

                }
                
                self.listOfFriends.sort {
                    let sum1 = $0.hoursSpent.reduce(0, +)
                    let sum2 = $1.hoursSpent.reduce(0, +)
                    print("sum1: ", sum1)
                    print("sum2: ", sum2)

                    return sum1 > sum2
                }
                
            }
            
        }
    }
}

