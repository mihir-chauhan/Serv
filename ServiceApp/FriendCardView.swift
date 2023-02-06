//
//  FriendCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI

struct FriendCardView: View {
    @EnvironmentObject var results: FirestoreCRUD
    var data: UserInfoFromAuth
    @State var listOfEventsFriendIsGoing: [EventInformationModel] = []
    @State var showingFriendDetailSheet: Bool = false
    @State var totalHours: Int = 0

    var body: some View {
        Button {
            showingFriendDetailSheet.toggle()
        } label: {
            HStack {
                AsyncImage(url: data.photoURL) { img in
                    img
                        .resizable()
//                        .cornerRadius(20)
                        .scaledToFill()
                        .frame(width: 65, height: 65)
//                        .padding(.leading, 6.5)

                        .cornerRadius(15)
                } placeholder: {
                    Color.gray
//                        .padding(.leading, 6.5)
                }
//                .clipShape(RoundedRectangle(cornerRadius: 20))

                .frame(width: 75, height: 75)
//                .clipped()
                
                .cornerRadius(15)
                    

                HStack {
                    VStack(alignment: .leading) {
                        Text("Total Hours: \(totalHours)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(data.displayName!)
                            .font(.title)
                            .fontWeight(.black)
                            .foregroundColor(.primary)
                        
                    }

                    Spacer()
                }
                .padding()
            }
            .background(Color("colorPrimary").opacity(0.4))
            .cornerRadius(15)
            
//            .overlay(
//                RoundedRectangle(cornerRadius: 10)
//                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
//            )
            .padding([.top, .horizontal], 5)
        }
//        .buttonStyle(CardButtonStyle())
        .sheet(isPresented: $showingFriendDetailSheet) {
            FriendDetailSheet(data: data, listOfEventsFriendIsGoing: $listOfEventsFriendIsGoing)
        }
        .task {
            totalHours = 0
            for hour in data.hoursSpent {
                totalHours += Int(hour)
            }
            FriendEventsInCommon().singularFriendEventRecognizer(uidFriend: data.uid) { events in
                for event in events {
                    results.getSpecificEvent(eventID: event) { eventName in
                        listOfEventsFriendIsGoing.append(eventName)
                        print("Events for \(data.uid)", listOfEventsFriendIsGoing.count)
                    }
                }
            }
        }
    }
}
