//
//  EventDetailView .swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct EventDetailView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    var data: EventInformationModel = EventInformationModel()
    @Binding var sheetMode: SheetMode
    var connectionResult = ConnectionResult.failure("OK!")
    @State var dragOffset: CGFloat = 0
    
    @State var reachedMaxSlotBool: Bool = false
    @State var buttonStateIsSignedUp: Bool = false
        
    @State var friendSignedUp: Bool = false
    @State var firstImage: [UIImage] = []
    @State var listOfFriendsWhoSignedUpForEvent: [String] = []
    
    @State var organizationData: OrganizationInformationModel?
    @State var expandInfo: Bool = false
    @State var infoSubviewHeight: CGFloat = 0
    
    var dateToString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            let stringDate = dateFormatter.string(from: data.time)
            return stringDate
        }
    }
    func checkForEventAdded(itemName: String, handler: @escaping (Bool?) -> ()) {
        FirebaseRealtimeDatabaseCRUD().readEvents(for: authViewModel.decodeUserInfo()!.uid) { eventsArray in
            if eventsArray == nil {
                buttonStateIsSignedUp = false
                handler(false);
            } else {
                var i = 0
                while i < eventsArray!.count {
                    if eventsArray![i] == itemName {
                        buttonStateIsSignedUp = true
                        handler(true)
                        return
                    }
                    i += 1
                }
                buttonStateIsSignedUp = false
                handler(false)
            }
            
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(data.name)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                    hapticResponse.impactOccurred()
                    self.sheetMode = .quarter
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.systemGray2))
                        .padding(12)
                }
            }
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(alignment: .leading) {
                    Text(data.category)
                        .font(.system(.headline))
                        .foregroundColor(.gray)
                    Text(self.dateToString)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<(self.firstImage.count), id: \.self) { img in
                                Group {
                                    if firstImage.count != 0 {
                                        Image(uiImage: firstImage[img])
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 150, height: 150)
                                            .clipped()
                                    }
                                }
                            }
                        }
                    }
                    
                    Text(data.description)
                        .font(.caption)
                        .padding(.bottom, 5)
                    Text("Special requirements:")
                        .bold()
                    Text(data.specialRequirements)
                        .font(.caption)
                        .padding(.bottom, 5)
                }
                
                VStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 40)
                        .foregroundColor(.clear)
                        .overlay(
                            HStack {
                                Label {
                                    Text("About Organization").bold()
                                } icon: {
                                    Image(systemName: "info.circle")
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                            }
                        )
                    VStack {
                        HStack {
                            Text("Name: ")
                                .bold()
                            Text(organizationData?.name ?? "Loading")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Address: ")
                                .bold()
                            Text(organizationData?.address ?? "Loading")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Email: ")
                                .bold()
                            Text(organizationData?.email ?? "Loading")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Phone: ")
                                .bold()
                            Text(organizationData?.phone ?? "Loading")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .fixedSize(horizontal: false, vertical: true)
                        HStack {
                            Text("Website: ")
                                .bold()
                            Text(organizationData?.website ?? "Loading")
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                }.background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
                .onPreferenceChange(ViewHeightKey.self) { infoSubviewHeight = $0 }
                .frame(height: expandInfo ? infoSubviewHeight : 35, alignment: .top)
                .padding()
                .clipped()
                .transition(.move(edge: .bottom))
                .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)))
                .onTapGesture {
                    print("organizationData: ", organizationData?.address ?? "Loading")
                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                    hapticResponse.impactOccurred()
                    withAnimation(.spring()) {
                        expandInfo.toggle()
                    }
                }
                .cornerRadius(20)

                
                HStack {
                    if friendSignedUp == true {
                        FriendsCommonEvent(listOfFriendsWhoSignedUpForEvent: $listOfFriendsWhoSignedUpForEvent)
                    }
                    Spacer()
                    Button(action: {
                        let responseHaptic = UIImpactFeedbackGenerator(style: .light)
                        FirestoreCRUD().checkForMaxSlot(eventID: data.FIRDocID!, eventCategory: data.category) { reachedMaxSlots in
                            if buttonStateIsSignedUp {
                                FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                                FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                buttonStateIsSignedUp = false
                                
                                responseHaptic.impactOccurred()
                            }
                            else if !reachedMaxSlots && !buttonStateIsSignedUp {
                                FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category)
                                FirebaseRealtimeDatabaseCRUD().writeEvents(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                buttonStateIsSignedUp = true
                                
                                responseHaptic.impactOccurred()
                            }
                            else if reachedMaxSlots {
                                reachedMaxSlotBool = true
                            }
                        }

                    }) {
                        Capsule()
                            .frame(width: 135, height: 45)
                            .foregroundColor(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? Color("colorTertiary") : .red) : .gray)
                            .overlay(Text(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? "Sign up" : "Remove Event") : "Reached Cap").foregroundColor(.white))
                    }.disabled(reachedMaxSlotBool)
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 15)
                .padding(.bottom, 175)
            }
            
        }
        .padding([.top, .trailing, .leading])
        .padding(.bottom, 200)
        .task {
            self.viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: sheetObserver.eventDetailData.coordinate.latitude - 0.02, longitude: sheetObserver.eventDetailData.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
            checkForEventAdded(itemName: data.FIRDocID!) { eventIs in
                buttonStateIsSignedUp = eventIs!
            }
            
            if checkForLiveEvents(date: data.time) == checkForLiveEvents(date: Date.now) {
//                self.eventIsLive.toggle()
            }
            FriendEventsInCommon().multipleFriendsEventRecognizer() { result in
                for (friend, events) in result {
                    for i in events! {
                        if i == data.FIRDocID {
                            //                                                        listOfFriendsWhoSignedUpForEvent?.append(friend)
                            print(friend)
                            listOfFriendsWhoSignedUpForEvent.append(friend)
                            friendSignedUp = true
                            //                                                        FriendsCommonEvent().friendsWhoSignedUp = self.listOfFriendsWhoSignedUpForEvent!
                        }
                    }
                }
            }
        }
        .task {
            firstImage = []
            for imageURL in data.images! {
                FIRCloudImages.getImage(gsURL: imageURL, eventID: data.FIRDocID!, eventDate: data.time) { image in
                    if(image!.size.height > 0 && image!.size.width > 0) {
                        firstImage.append(image!)
                    }
                }
            }
            FirestoreCRUD().getOrganizationDetail(ein: data.ein) { value in
                organizationData = value!
            }
        }
        .onChange(of: data) { value in
            self.viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: sheetObserver.eventDetailData.coordinate.latitude - 0.02, longitude: sheetObserver.eventDetailData.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
            reachedMaxSlotBool = false
            friendSignedUp = false
            listOfFriendsWhoSignedUpForEvent = []
            checkForEventAdded(itemName: value.FIRDocID!) { eventIs in
                buttonStateIsSignedUp = eventIs!
            }
            
            if checkForLiveEvents(date: value.time) == checkForLiveEvents(date: Date.now) {
//                self.eventIsLive.toggle()
            }
            FriendEventsInCommon().multipleFriendsEventRecognizer() { result in
                for (friend, events) in result {
                    for i in events! {
                        if i == value.FIRDocID {
                            //                                                        listOfFriendsWhoSignedUpForEvent?.append(friend)
                            print(friend)
                            listOfFriendsWhoSignedUpForEvent.append(friend)
                            friendSignedUp = true
                            //                                                        FriendsCommonEvent().friendsWhoSignedUp = self.listOfFriendsWhoSignedUpForEvent!
                        }
                    }
                }
            }

            
            firstImage = []
            for imageURL in value.images! {
                FIRCloudImages.getImage(gsURL: imageURL, eventID: value.FIRDocID!, eventDate: value.time) { image in
                    if(image!.size.height > 0 && image!.size.width > 0) {
                        firstImage.append(image!)
                    }
                }
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

private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
