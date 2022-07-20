//
//  FriendDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI
import SwiftUICharts
import SDWebImageSwiftUI

struct ScheduleCardDetailSheet: View {
    @Binding var data: EventInformationModel
    
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    
    @State var buttonStateIsSignedUp: Bool = false
    @State var viewOrganization = false
    
    func checkForEventAdded(itemName: String, handler: @escaping (Bool?) -> ()) {
        FirebaseRealtimeDatabaseCRUD().readEvents(for: user_uuid!) { eventsArray in
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
        ScrollView(showsIndicators: false) {
            VStack {
                WebImage(url: self.placeHolderImage[0])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .clipped()
                    .cornerRadius(15, corners: [.topLeft, .topRight])
                    .padding(.bottom, 10)
                VStack(alignment: .leading) {
                Text(data.name)
                    .font(.system(size: 30))
                    .fontWeight(.bold)

                    Text(data.description).font(.system(.caption))
                        .padding(.horizontal, 5)
                
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
                
                HStack {
                    Text("Proudly hosted by \(data.host)").bold()
                    Button(action: {
                        viewOrganization.toggle()
                    }) {
                    Image(systemName: "info.circle")
                        .foregroundColor(.orange)
                    }
                }
                
                HStack {
                    Spacer()
                    Button(action: {
                        if !buttonStateIsSignedUp {
                            FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!)
                            FirebaseRealtimeDatabaseCRUD().writeEvents(for: user_uuid!, eventUUID: data.FIRDocID!)
                        } else {
                            FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, user_uuid: user_uuid!)
                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid!, eventUUID: data.FIRDocID!)
                        }
                        
                        buttonStateIsSignedUp.toggle()
                    }) {
                        Capsule()
                            .frame(width: 135, height: 45)
                            .foregroundColor(!buttonStateIsSignedUp ? .blue : .red)
                            .overlay(Text(!buttonStateIsSignedUp ? "Sign up" : "Remove Event").foregroundColor(.white))
                    }
                }
                .padding(.vertical, 30)
                .padding(.horizontal, 15)
                .padding(.bottom, 20)
                }.padding(15)
            }
        }
        
//        .onAppear {
//            checkForEventAdded(itemName: data.FIRDocID!) { eventIs in
//                buttonStateIsSignedUp = eventIs!
//            }
//            FIRCloudImagesUSED().getRemoteImages(gsURL: data.images!) { connectionResult in
//                switch connectionResult {
//                case .success(let url):
//                    self.placeHolderImage.removeAll()
//                    self.placeHolderImage = url
//
//                case .failure(let error):
//                    print(error)
//                }
//            }
//        }
        .fullScreenCover(isPresented: $viewOrganization) {
            OrganizationDetailView(ein: data.ein)
        }
    }
}
