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
    var body: some View {
        NavigationView {
            ScrollView {
                LeaderboardView().padding(.bottom, 50)
                ForEach(self.listOfFriends, id: \.self) { friend in
                    FriendCardView(image: friend.photoURL ?? imgForDetailSheet, lastService: "5", name: friend.displayName!, onTapCallback: cardTapped)
                        .sheet(isPresented: $showingFriendDetailSheet) {
                            FriendDetailSheet(data: friend)
                        }
                }.padding(.horizontal)
//                FriendCardView(image: "person", lastService: "5", name: "Tom", onTapCallback: cardTapped)
//                FriendCardView(image: "img", lastService: "9", name: "Jill", onTapCallback: cardTapped)
//                FriendCardView(image: "img4", lastService: "10", name: "Mary", onTapCallback: cardTapped)
//                FriendCardView(image: "leaderboardPic-2", lastService: "46", name: "Robert", onTapCallback: cardTapped).padding(.bottom, 50)
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
            }
            
        }
        .onAppear {
            FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { allFriends in
                self.listOfFriends.removeAll()
                for friend in allFriends {
                    FirebaseRealtimeDatabaseCRUD().getUserFriendInfo(uid: friend) { friendInfo in
                        self.listOfFriends.append(friendInfo)
                    }
                }
                
            }
        }
    }
    
    func cardTapped(name: String, img: URL) {
        nameForDetailSheet = name
        imgForDetailSheet = img
        showingFriendDetailSheet.toggle()
    }
}

