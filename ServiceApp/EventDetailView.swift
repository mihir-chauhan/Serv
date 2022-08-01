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
    
    @State var buttonStateIsSignedUp: Bool = false
    
    //    var drag: some Gesture {
    //        DragGesture(minimumDistance: 50)
    //
    //                                .onChanged({ value in
    //            self.dragOffset = value.translation.height
    //        })
    //                                .onEnded({ value in
    //            self.sheetMode = .quarter
    //            self.dragOffset = 0
    //        })
    //    }
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
        }
    }
}
