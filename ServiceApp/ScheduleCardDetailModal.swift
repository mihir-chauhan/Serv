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
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    
    @State var buttonStateIsSignedUp: Bool = false
    @State var viewOrganization = false
    
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
                            FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category)
                            FirebaseRealtimeDatabaseCRUD().writeEvents(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                        } else {
                            FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
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
        .fullScreenCover(isPresented: $viewOrganization) {
            OrganizationDetailView(ein: data.ein)
        }
    }
}
