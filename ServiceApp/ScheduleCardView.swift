//
//  ScheduleCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 12/31/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ScheduleCard: View {
    var animation: Namespace.ID
    var data: EventInformationModel
    var onDelete: () -> ()
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentlyPresentedScheduleCard: CurrentlyPresentedScheduleCard
    @State var showingAlert = false
    @State var placeHolderUIImage: UIImage?
    @State var viewRendered = false
    @State var toggleCheckInSheet = false
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    //    var onTapCallback : (EventInformationModel) -> ()
    
    @State var eventIsLive: Bool = false
    @State var eventExistsInUser: Bool = false
    
    @State var friendSignedUp: Bool = false
    
    @State var listOfFriendsWhoSignedUpForEvent: [String] = []
    
    @Binding var show: Bool
    
    var body: some View {
        
        Button {
            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
            hapticResponse.impactOccurred()
            self.currentlyPresentedScheduleCard.currentlyShowing = data
            withAnimation(.spring()) {
                show.toggle()
            }
        } label: {
            if !self.viewRendered {
                ProgressView().frame(width: 290, height: 250)
                    .task {
                        FIRCloudImages.getImage(gsURL: data.images![0], eventID: data.FIRDocID!, eventDate: data.time) { image in
                            self.placeHolderUIImage = image!
                            self.viewRendered = true
                        }
                        
                        print("cache size", URLCache.shared.memoryCapacity / 1024)
                    }
            } else {
                VStack {
                    // image can be removed later on if we dont want to have the host of the event add it
                    ZStack(alignment: .top) {
                        if let imageLoaded = self.placeHolderUIImage {
                            Image(uiImage: imageLoaded)
                            //                            Image("leaderboardPic-1")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .matchedGeometryEffect(id: "id", in: animation, properties: .size)
                            //                                .matchedGeometryEffect(id: "Shape", in: animation)
                        }
                        
                        //
                        HStack {
                            Spacer()
                            HStack(alignment: .top, spacing: 15) {
                                //TODO: check if an event exists in a user's list for realtime db
                                if ( (eventExistsInUser) && (data.time.dateToString(style: "MM/dd/yyyy") == Date.now.dateToString(style: "MM/dd/yyyy")) ) {
                                    Button(action: {
                                        self.toggleCheckInSheet.toggle()
                                    }) {
                                        Capsule()
                                            .frame(width: 100, height: 32.5)
                                            .foregroundColor(Color(.systemGray4).opacity(0.95))
                                            .overlay(Text("Check In").foregroundColor(.primary))
                                            .padding(5)
                                    }
                                }
                            }
                        }
                    }
                    .task {
                        FirebaseRealtimeDatabaseCRUD().checkIfEventExistsInUser(uuidString: authViewModel.decodeUserInfo()!.uid, eventToCheck: data.FIRDocID!) { res in
                            switch res {
                            case true:
                                eventExistsInUser = true
                            case false:
                                eventExistsInUser = false
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: {
                            FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        }
                    }.tint(.clear)
                    
                    ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top)) {
                        VStack(alignment: .leading) {
                            HStack {
                                
                                Text(data.category)
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Spacer(minLength: 20)
                                Button(action: {
                                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                    hapticResponse.impactOccurred()
                                    let url = URL(string: "maps://?saddr=&daddr=\(data.coordinate.latitude),\(data.coordinate.longitude)")
                                    if UIApplication.shared.canOpenURL(url!) {
                                        UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                    }
                                }) {
                                    Image(systemName: "location.north.circle.fill")
                                        .renderingMode(.original)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                }
                                
                                Image(systemName: "trash.circle.fill")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color(.red))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                                        hapticResponse.impactOccurred()
                                        showingAlert = true
                                    }
                                    .alert("Are you sure you want to remove the event?", isPresented: $showingAlert) {
                                        Button("Cancel", role: .cancel) { }
                                        Button("Remove", role: .destructive) {
                                            self.onDelete()
                                            FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                        }
                                    }
                            }
                            Text(data.name)
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.primary)
                            //.lineLimit(3) maybe we dont need it...maybe we dooo?
                            HStack {
                                VStack(alignment: .leading) {
                                    HStack {
                                        Text(data.time, formatter: dateFormatter)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        ZStack {
                                            Circle().foregroundColor(.red.opacity(0.25)).frame(width: 35, height: 35).scaleEffect(eventIsLive ? 1 : 0)
                                            Circle().foregroundColor(.red.opacity(0.35)).frame(width: 25, height: 25).scaleEffect(eventIsLive ? 1 : 0)
                                            Circle().foregroundColor(.red.opacity(0.45)).frame(width: 15, height: 15).scaleEffect(eventIsLive ? 1 : 0)
                                            Circle().foregroundColor(eventIsLive ? .red : .clear).frame(width: 9, height: 9)
                                        }
                                        .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                                        Text("LIVE").foregroundColor(self.eventIsLive ? .red : .clear).bold().font(.system(.subheadline))
                                        Spacer()
                                    }
                                    
                                    .task {
                                        if data.time.dateToString(style: "MM/dd/yyyy") == Date.now.dateToString(style: "MM/dd/yyyy") {
                                            self.eventIsLive.toggle()
                                            
                                        }
                                        FriendEventsInCommon().multipleFriendsEventRecognizer() { result in
                                            for (friend, events) in result {
                                                for i in events! {
                                                    if i == data.FIRDocID {
                                                        //                                                        listOfFriendsWhoSignedUpForEvent?.append(friend)
                                                        print(friend)
                                                        listOfFriendsWhoSignedUpForEvent.append(friend)
                                                        friendSignedUp = true
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                                
                                
                                if friendSignedUp == true {
                                    FriendsCommonEvent(listOfFriendsWhoSignedUpForEvent: $listOfFriendsWhoSignedUpForEvent)
                                }
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.25)))
                .cornerRadius(15)
                .padding([.top, .horizontal])
            }
        }
        .buttonStyle(CardButtonStyle())
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(action: {
                
            }) {
                Image(systemName: "trash")
            }
        }
        .sheet(isPresented: $toggleCheckInSheet) {
            CheckInView(data: data)
        }
    }
}


struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}
