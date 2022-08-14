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
    
    @State var haveFriends: Bool = false
    var body: some View {
        NavigationView {
            ScrollView {
                LeaderboardView(listOfFriends: listOfFriends)
                    .padding(.bottom, 50)
                    .overlay(
                        haveFriends ? nil : CustomMaterialEffectBlur(blurStyle: .systemUltraThinMaterial).cornerRadius(25).offset(y: -10).overlay(Text("Leaderboard would appear after you add friends").font(.headline).bold().padding())
                    )
                if self.listOfFriends.isEmpty {
                    
                    Text("No friends to show!").font(.title).bold()
                        .offset(y: UIScreen.main.bounds.height / 5)
                    
                } else {
                    ForEach(self.listOfFriends, id: \.self) { friend in
                        
                        FriendCardView(data: friend)
                            .sheet(isPresented: $showingFriendDetailSheet) {
                                let _ = print("FRIEND INFO SHOWING:", friend.displayName)
                                FriendDetailSheet(data: friend)
                            }
                    }.padding(.horizontal)
                }
            }
            .navigationTitle("Socials")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
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
                        FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { allFriends in
                            self.listOfFriends.removeAll()
                            for friend in allFriends {
                                if !allFriends.isEmpty { haveFriends = true }
                                FirebaseRealtimeDatabaseCRUD().getUserFriendInfo(uid: friend) { friendInfo in
                                    self.listOfFriends.append(friendInfo)
                                }
                            }
                            
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
                print("ALL MY FRIENDS", self.listOfFriends)
            }
        }
    }
}

