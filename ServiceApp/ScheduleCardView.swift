//
//  ScheduleCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 12/31/21.
//

import SwiftUI
import SDWebImageSwiftUI

struct ScheduleCard: View {
    var data: EventInformationModel
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
    
    var onTapCallback : (EventInformationModel) -> ()
    
    @State var eventIsLive: Bool = false
    @State var eventExistsInUser: Bool = false
    
    @State var friendSignedUp: Bool = false
    
    @State var listOfFriendsWhoSignedUpForEvent: [String]?

    var body: some View {
        if #available(iOS 15.0, *) {
            Button {
                self.onTapCallback(data)
            } label: {
                if !self.viewRendered {
                    ProgressView().frame(width: 290, height: 250)
                        .onAppear {
                            FIRCloudImages.getImage(gsURL: data.images![0]) { image in
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
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
//                        WebImage(url: self.placeHolderImage)
//
                        HStack {
                            Spacer()
                            HStack(alignment: .top, spacing: 15) {
                            //TODO: check if an event exists in a user's list for realtime db
                                if ( (eventExistsInUser) && (checkForLiveEvents(date: data.time) == checkForLiveEvents(date: Date.now)) ) {
                                    Button(action: {
                                        self.toggleCheckInSheet.toggle()
                                    }) {
                                        Capsule()
                                            .frame(width: 100, height: 32.5)
                                            .foregroundColor(Color(.systemGray4).opacity(0.95))
                                            .overlay(Text("Check In").foregroundColor(.primary))
                                            .padding(.top, 5)
                                    }
                                }
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 65, height: 65)
                                    .foregroundColor(Color(.systemGray4).opacity(0.95))
                                    .overlay(Text(data.category == "Humanitarian" ? "🤝🏿" : "🌲").font(.system(size: 40))).padding([.top, .trailing], 5)
                                
                            }
                        }
                    }
                    .onAppear {
                        FirebaseRealtimeDatabaseCRUD().checkIfEventExistsInUser(uuidString: user_uuid!, eventToCheck: data.FIRDocID!) { res in
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
                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid!, eventUUID: data.FIRDocID!)
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
                                Image(systemName: "location.north.circle.fill")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        let url = URL(string: "maps://?saddr=&daddr=\(data.coordinate.latitude),\(data.coordinate.longitude)")
                                        if UIApplication.shared.canOpenURL(url!) {
                                              UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                                        }
                                    }
                                Image(systemName: "trash.circle.fill")
                                    .renderingMode(.original)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(Color(.red))
                                    .frame(width: 25, height: 25)
                                    .onTapGesture {
                                        showingAlert = true
                                    }
                                    .alert("Are you sure you want to delete the event?", isPresented: $showingAlert) {
                                        Button("cancel", role: .cancel) { }
                                        Button("delete", role: .destructive) {
                                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid!, eventUUID: data.FIRDocID!)
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
                                    .onAppear {
                                        if checkForLiveEvents(date: data.time) == checkForLiveEvents(date: Date.now) {
                                            self.eventIsLive.toggle()
//                                            data.FIRDocID #error() //TODO: AHA
                                            
                                        }
                                        FriendEventsInCommon().test() { result in
                                            for (friend, events) in result {
                                                for i in events! {
                                                    if i == data.FIRDocID {
                                                        friendSignedUp = true
                                                        
                                                        listOfFriendsWhoSignedUpForEvent?.append(friend)
//                                                        FriendsCommonEvent().friendsWhoSignedUp = self.listOfFriendsWhoSignedUpForEvent!
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                                        
                                        Text("LIVE").foregroundColor(self.eventIsLive ? .red : .clear).bold().font(.system(.subheadline))
                                    }
                                }
                                Spacer()
                                
                                if friendSignedUp == true {
                                   FriendsCommonEvent()
                                }
                            }
                            
                        }
                        
                    }
                    .padding()
                }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                )
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
    
    func checkForLiveEvents(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
}


struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}
