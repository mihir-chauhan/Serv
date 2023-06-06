//
//  EventDetailView .swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import MapKit
import MessageUI
import FirebaseAnalytics
import AlertToast

struct EventDetailView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @EnvironmentObject var sheetObserver: SheetObserver
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @EnvironmentObject var authVM: AuthViewModel
    var data: EventInformationModel = EventInformationModel()
    @Binding var sheetMode: SheetMode
    
    @State var reachedMaxSlotBool: Bool = false
    @State var buttonStateIsSignedUp: Bool = false
    
    @State var friendSignedUp: Bool = false
    @State var firstImage: [UIImage] = []
    @State var listOfFriendsWhoSignedUpForEvent: [String] = []
    
    @State var organizationData: OrganizationInformationModel?
    
    @State var expandSpecialReqInfo: Bool = false
    @State var expandOrganizationInfo: Bool = false
    
    @State var showingAlert: Bool = false
    
    func checkForEventAdded(itemName: String, handler: @escaping (Bool?) -> ()) {
        FirebaseRealtimeDatabaseCRUD().readEvents(for: authVM.decodeUserInfo()!.uid) { eventsArray in
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
                    HStack {
                        VStack {
                            Text(data.category)
                                .font(.system(.headline))
                                .foregroundColor(.gray)
                            Text(data.time.dateToString())
                        }
                        Spacer()
                        Button(action: {
                            FirebaseRealtimeDatabaseCRUD().writeToBookmarks(for: authVM.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                            showingAlert.toggle()
                        }) {
                            Image(systemName: "bookmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 25, height: 25)
                                .foregroundColor(.blue)

                        }
                    }
                    
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
                    Text("Description")
                        .bold()
                    Text(data.description)
                        .font(.caption)
                        .padding(.bottom, 5)
                }
                
                SpecialRequirementsInfoCard(specialRequirements: data.specialRequirements, expandInfo: $expandSpecialReqInfo)
                // Organization Card Collapsible View
                OrganizationInfoCard(organizationData: $organizationData, expandInfo: $expandOrganizationInfo)

                
                HStack {
                    if friendSignedUp == true {
                        FriendsCommonEvent(listOfFriendsWhoSignedUpForEvent: $listOfFriendsWhoSignedUpForEvent)
                    }
                    Spacer()
                    
                    if data.usesCheckInOut {
                        Button(action: {
                            let responseHaptic = UIImpactFeedbackGenerator(style: .light)
                            authVM.apnsToken = delegate.apnsToken
                            FirebaseRealtimeDatabaseCRUD().updateApnsToken(uid: authVM.decodeUserInfo()!.uid, token: authVM.apnsToken)
                            FirestoreCRUD().checkForMaxSlot(eventID: data.FIRDocID!, eventCategory: data.category) { reachedMaxSlots in
                                if buttonStateIsSignedUp {
                                    FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authVM.decodeUserInfo()!.uid)
                                    FirebaseRealtimeDatabaseCRUD().removeEvent(for: authVM.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                    buttonStateIsSignedUp = false
                                    
                                    responseHaptic.impactOccurred()
                                }
                                else if !reachedMaxSlots && !buttonStateIsSignedUp {
                                    
                                    FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, apnsToken: authVM.apnsToken)
                                    FirebaseRealtimeDatabaseCRUD().writeEvents(for: authVM.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                    buttonStateIsSignedUp = true
                                    
                                    let parameters: [String : String] = [
                                        "event" : data.FIRDocID!,
                                        "user" : authVM.decodeUserInfo()!.uid
                                    ]
                                    Analytics.logEvent("event signed up", parameters: parameters)
                                    
                                    responseHaptic.impactOccurred()
                                }
                                else if reachedMaxSlots {
                                    reachedMaxSlotBool = true
                                }
                            }
                            
                        }) {
                            Capsule()
                                .frame(width: 135, height: 45)
                                .foregroundColor(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? .green : .red) : .gray)
                                .overlay(Text(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? "Sign up" : "Remove Event") : "Reached Cap").foregroundColor(.white))
                        }.disabled(reachedMaxSlotBool)
                    }
                    else {
                        Button(action: {
                            //TODO: takes them to external link
                            if let url = URL(string: "https://www.google.com") {
                                   UIApplication.shared.open(url)
                                }
                        }) {
                            Capsule()
                                .frame(width: 135, height: 45)
                                .foregroundColor(.blue)
                                .overlay(Text("Register").foregroundColor(.white))
                        }
                    }
                    
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 15)
                .padding(.bottom, 175)
            }
            
        }
        .toast(isPresenting: $showingAlert) {
            AlertToast(type: .complete(.green), title: "Bookmarked")
        }
        .padding([.top, .trailing, .leading])
        .padding(.bottom, 200)
        .task {
            self.viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: sheetObserver.eventDetailData.coordinate.latitude - 0.02, longitude: sheetObserver.eventDetailData.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
            checkForEventAdded(itemName: data.FIRDocID!) { eventIs in
                buttonStateIsSignedUp = eventIs!
            }
            
            FriendEventsInCommon().multipleFriendsEventRecognizer() { result in
                for (friend, events) in result {
                    for i in events! {
                        if i == data.FIRDocID {
                            print(friend)
                            listOfFriendsWhoSignedUpForEvent.append(friend)
                            friendSignedUp = true
                            
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
            
            FriendEventsInCommon().multipleFriendsEventRecognizer() { result in
                for (friend, events) in result {
                    for i in events! {
                        if i == value.FIRDocID {
                            print(friend)
                            listOfFriendsWhoSignedUpForEvent.append(friend)
                            friendSignedUp = true
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
}

