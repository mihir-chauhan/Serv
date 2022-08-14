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
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    @State var dragOffset: CGFloat = 0
    
    @State var reachedMaxSlotBool: Bool = false
    @State var buttonStateIsSignedUp: Bool = false
    
    @State var eventExistsInUser: Bool = false
    
    @State var friendSignedUp: Bool = false
    
    @State var listOfFriendsWhoSignedUpForEvent: [String] = []
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
                    self.sheetMode = .quarter
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.systemGray2))
                        .padding(12)
                }
            }
            ScrollView {
                
                VStack(alignment: .leading) {
                    Text(data.category)
                        .font(.system(.headline))
                        .foregroundColor(.gray)
                    Text(self.dateToString)
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<self.placeHolderImage.count, id: \.self) { img in
                                WebImage(url: self.placeHolderImage[img])
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 150, height: 150)
                                    .clipped()
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
                }
                
                HStack {
                    if friendSignedUp == true {
                        FriendsCommonEvent(listOfFriendsWhoSignedUpForEvent: $listOfFriendsWhoSignedUpForEvent)
                    }
                    Spacer()
                    Button(action: {
                        FirestoreCRUD().checkForMaxSlot(eventID: data.FIRDocID!, eventCategory: data.category) { reachedMaxSlots in
                            if buttonStateIsSignedUp {
                                FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                                FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                FirestoreCRUD().checkForMaxSlot(eventID: data.FIRDocID!, eventCategory: data.category) { newValue in
                                    if !newValue {
                                        buttonStateIsSignedUp.toggle()
                                        reachedMaxSlotBool = false
                                    }
                                }
                            }
                            if !reachedMaxSlots {
                                    FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category)
                                    FirebaseRealtimeDatabaseCRUD().writeEvents(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                
                                
                                buttonStateIsSignedUp.toggle()
                            } else {
                                reachedMaxSlotBool = true
                            }
                        }

                    }) {
                        Capsule()
                            .frame(width: 135, height: 45)
                            .foregroundColor(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? .blue : .red) : .gray)
                            .overlay(Text(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? "Sign up" : "Remove Event") : "Reached Cap").foregroundColor(.white))
                    }.disabled(reachedMaxSlotBool)
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 15)
                .padding(.bottom, 200)
            }
            
        }
        
        .padding([.top, .trailing, .leading])
        .padding(.bottom, 200)
        .task {
            self.viewModel.region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: sheetObserver.eventDetailData.coordinate.latitude - 0.02, longitude: sheetObserver.eventDetailData.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03))
            
            checkForEventAdded(itemName: data.FIRDocID!) { eventIs in
                buttonStateIsSignedUp = eventIs!
            }
            FIRCloudImagesUSED().getRemoteImages(gsURL: data.images!) { connectionResult in
                switch connectionResult {
                case .success(let url):
                    self.placeHolderImage.removeAll()
                    self.placeHolderImage = url
                    
                case .failure(let error):
                    print(error)
                }
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
        
    }
    func checkForLiveEvents(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
    }
}
