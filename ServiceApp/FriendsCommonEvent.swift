//
//  FriendsCommonEvent.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI

struct FriendsCommonEvent: View {
    var imgArray = ["leaderboardPic-1", "leaderboardPic-2", "leaderboardPic-3", "img", "img4", "img2", "person", "community-service"]
    var img1Name = "leaderboardPic-1"
    var img2Name = "leaderboardPic-2"
    var img3Name = "leaderboardPic-3"
    
    @Binding var listOfFriendsWhoSignedUpForEvent: [String]
    
    @State var listOfFriendProfilePictures: [URL] = []
    
    var body: some View {
//        Group {
//            if listOfFriendsWhoSignedUpForEvent.isEmpty {
//                Text("No friends")
//            } else {
        Button(action: {
            
        }) {
                HStack(spacing: -15) {
//                    TODO: async image based on given ID, display image based on url given in realtime database
                    ForEach(listOfFriendProfilePictures, id: \.self) { picture in
                        AsyncImage(url: picture) { phase in
                            switch phase {
                            case .empty:
                                Color.purple.opacity(0.1)
                            case .success(let image):
                                image
                                    .pfpIconModifier()
                            case .failure(_):
                                Image(systemName: "exclamationmark.icloud")
                                    .pfpIconModifier()
                            @unknown default:
                                Image(systemName: "exclamationmark.icloud")
                                    .pfpIconModifier()
                            }
                        }
                    }
                }
                }.padding([.bottom, .horizontal], 10)
                    .task {
                        for friend in listOfFriendsWhoSignedUpForEvent {
                            FirebaseRealtimeDatabaseCRUD().getProfilePictureFromURL(uid: friend) { photoURL in
                                print("DAY6", photoURL)
                                listOfFriendProfilePictures.append(photoURL)
                            }
                        }
        }

        
    }
}

extension Image {
    func pfpIconModifier() -> some View  {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: display.width / 8, height: display.width / 8)
            
            .scaleEffect(1.35)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}
