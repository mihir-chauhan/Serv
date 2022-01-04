//
//  Socials.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct Socials: View {
    @State private var showingSheet = false
    @State private var showingFriendDetailSheet = false
    @State private var nameForDetailSheet = "you"
    var body: some View {
        NavigationView {
            ScrollView {
                LeaderboardView()

                FriendCardView(image: "person", lastService: "10", name: "you", onTapCallback: cardTapped)
                FriendCardView(image: "person", lastService: "11", name: "me", onTapCallback: cardTapped)
                FriendCardView(image: "person", lastService: "12", name: "us", onTapCallback: cardTapped)
            }
            .navigationTitle("Socials")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing
                ) {
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
            .sheet(isPresented: $showingFriendDetailSheet) {
                FriendDetailSheet(name: nameForDetailSheet)
            }
        }
    }
    
    func cardTapped(name: String) {
        nameForDetailSheet = name
        showingFriendDetailSheet.toggle()
    }

}

struct Socials_Previews: PreviewProvider {
    static var previews: some View {
        Socials()
    }
}
