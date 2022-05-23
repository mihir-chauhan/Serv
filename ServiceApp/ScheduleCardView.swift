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
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    var onTapCallback : (EventInformationModel) -> ()
    
    @State var pulsingAnimationForLiveEvent: Bool = false

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
                                VStack(alignment: .leading) {
                                Text(data.time, formatter: dateFormatter)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    ZStack {
                                        Circle().foregroundColor(.red.opacity(0.25)).frame(width: 35, height: 35).scaleEffect(pulsingAnimationForLiveEvent ? 1 : 0)
                                        Circle().foregroundColor(.red.opacity(0.35)).frame(width: 25, height: 25).scaleEffect(pulsingAnimationForLiveEvent ? 1 : 0)
                                        Circle().foregroundColor(.red.opacity(0.45)).frame(width: 15, height: 15).scaleEffect(pulsingAnimationForLiveEvent ? 1 : 0)
                                        Circle().foregroundColor(.red).frame(width: 9, height: 9)
                                    }
                                    .onAppear {
                                        if checkForLiveEvents(date: data.time) == checkForLiveEvents(date: Date.now) {
                                            self.pulsingAnimationForLiveEvent.toggle()
                                        }
                                    }
                                    .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                                }
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
            }
            .buttonStyle(CardButtonStyle())
            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                Button(action: {
                    
                }) {
                    Image(systemName: "trash")
                }
            }
            
            
        }
    }
    
    private func checkForLiveEvents(date: Date) -> String {
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
