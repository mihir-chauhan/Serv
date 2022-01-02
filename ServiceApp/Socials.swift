//
//  Socials.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct Socials: View {
    @State private var showingSheet = false
    var body: some View {
        NavigationView {
            ScrollView {
                FriendCardView(image: "community-service", lastService: "10", name: "you")
                FriendCardView(image: "community-service", lastService: "11", name: "me")
                FriendCardView(image: "community-service", lastService: "12", name: "us")
                
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
        }
    }
}

struct Socials_Previews: PreviewProvider {
    static var previews: some View {
        Socials()
    }
}
