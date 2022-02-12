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
    @State var placeHolderImage = URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")
    
    var dateToString: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyy"
        let stringDate = dateFormatter.string(from: Date())
        return stringDate
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var onTapCallback : (EventInformationModel) -> ()
    
    var body: some View {
        if #available(iOS 15.0, *) {
            Button {
                self.onTapCallback(data)
            } label: {
                VStack {
                    // image can be removed later on if we dont want to have the host of the event add it
                    ZStack(alignment: .top) {
                        WebImage(url: self.placeHolderImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                        HStack {
                            Spacer()
                            HStack {
                                RoundedRectangle(cornerRadius: 50)
                                    .frame(width: 65, height: 65)
                                    .foregroundColor(Color(.systemGray4))
                                    .overlay(Text(data.category == "Humanitarian" ? "🤝🏿" : "🌲").font(.system(size: 40))).padding([.top, .trailing], 5)
                                
                            }
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(action: {
                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid, eventUUID: data.FIRDocID!)
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
                                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: user_uuid, eventUUID: data.FIRDocID!)
                                        }
                                    }
                            }
                            Text(data.name)
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.primary)
                            //.lineLimit(3) maybe we dont need it...maybe we dooo?
                            HStack {
                                Text(data.time, formatter: dateFormatter)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                FriendsCommonEvent()
                            }
                            
                        }
                        
                    }
                    //                    .layoutPriority(100)
                    
                    
                    .padding()
                }
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                )
                .padding([.top, .horizontal])
            }
            .buttonStyle(CardButtonStyle())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    
                }) {
                    Image(systemName: "trash")
                }
            }
            .onAppear {
                FIRCloudImages().getRemoteImages(gsURL: data.images!) { connectionResult in
                    switch connectionResult {
                    case .success(let url):
                        self.placeHolderImage = url[0]
                    case .failure(let error):
                        print(error)
                    }
                }
            }
        }
    }
}


struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}
