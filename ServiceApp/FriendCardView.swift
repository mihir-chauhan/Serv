//
//  FriendCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI

struct FriendCardView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
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
                        .scaledToFill()
                } placeholder: {
                    Color.gray
                }
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .frame(width: 65, height: 65)
                .clipped()
                .padding(.leading, 6.5)
                    

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
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
            )
            .padding([.top, .horizontal], 5)
        }
//        .buttonStyle(CardButtonStyle())
        .sheet(isPresented: $showingFriendDetailSheet) {
            FriendDetailSheet(data: data, listOfEventsFriendIsGoing: listOfEventsFriendIsGoing)
        }
        .task {
            totalHours = 0
            for hour in data.hoursSpent {
                totalHours += Int(hour)
            }
            print("!!!uuid:", data.uid)
            authViewModel.queryAllCategoriesClosure(resetAllToTrue: false) { result in
                FriendEventsInCommon().singularFriendEventRecognizer(uidFriend: data.uid) { events in
                    for event in events {
                        print("Events Count", event)
                        FirestoreCRUD().getSpecificEvent(eventID: event) { eventName in
                            listOfEventsFriendIsGoing.append(eventName)
                            print("Events", eventName)
                        }
                    }
                }
            }
        }
    }
}
