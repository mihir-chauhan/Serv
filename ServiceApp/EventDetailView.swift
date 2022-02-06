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
    @FetchRequest(entity: UserEvent.entity(), sortDescriptors: []) public var fetchedResult: FetchedResults<UserEvent>
    var data: EventInformationModel = EventInformationModel()
    @Binding var sheetMode: SheetMode
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://via.placeholder.com/150x150.jpg")]
    @State var dragOffset: CGFloat = 0
    
    @State var buttonStateIsSignedUp: Bool = false
    
    var drag: some Gesture {
        DragGesture(minimumDistance: 50)
                                
                                .onChanged({ value in
            self.dragOffset = value.translation.height
        })
                                .onEnded({ value in
            self.sheetMode = .quarter
            self.dragOffset = 0
        })
    }
    var dateToString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            let stringDate = dateFormatter.string(from: data.time)
            return stringDate
        }
    }
    func checkForEventAdded(itemName: String, handler: @escaping (Bool?) -> ()) {
        FirebaseRealtimeDatabaseCRUD().readEvents(for: user_uuid) { eventsArray in
            if eventsArray == nil {
                buttonStateIsSignedUp = false
                handler(false);
            } else {
                var i = 0
                while i < eventsArray!.count {
                    print("sadaldsfadsfasdlkjfdkfndsflkjsdanf: ", eventsArray![i], itemName)
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
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                        }
                    }
                }
                Text(data.description)
                    .font(.caption)
            }
            HStack {
                Spacer()
                Button(action: {
                    if !buttonStateIsSignedUp {
                        FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!)
                        FirebaseRealtimeDatabaseCRUD().writeEvents(for: user_uuid, eventUUID: data.FIRDocID!)
                    } else {
                        // TODO: remove user event from core data
                        FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, user_uuid: user_uuid)
                        FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid, eventUUID: data.FIRDocID!)
                    }
                    
                    buttonStateIsSignedUp.toggle()
//                    self.sheetMode = .quarter
                }) {
                    Capsule()
                        .frame(width: 135, height: 45)
                        .foregroundColor(!buttonStateIsSignedUp ? .blue : .red)
                        .overlay(Text(!buttonStateIsSignedUp ? "Sign up" : "Remove Event").foregroundColor(.white))
                }
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 15)
            Spacer()
                
        }
        .simultaneousGesture(self.drag)
        .padding()
        .onAppear {
            checkForEventAdded(itemName: data.FIRDocID!) { eventIs in
                buttonStateIsSignedUp = eventIs!
            }
            FIRCloudImages().getRemoteImages(gsURL: data.images!) { connectionResult in
                switch connectionResult {
                case .success(let url):
                    self.placeHolderImage.removeAll()
                    self.placeHolderImage = url
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
