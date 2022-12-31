//
//  ScheduleCardDetailView.swift
//  ServiceApp
//
//  Created by Kelvin J on 12/29/22.
//

import SwiftUI

struct ScheduleCardDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentlyPresentedScheduleCard: CurrentlyPresentedScheduleCard
    //    var data: EventInformationModel
    @State var eventImages: [UIImage] = []
    @State var expandUpdates: Bool = false
    @State var subviewHeight : CGFloat = 0
    @State var viewRendered = false
    @State var placeHolderUIImage: UIImage?
    @State var showingAlert = false

    @Namespace private var namespace
    @Binding var show: Bool
    @Binding var toggleHeroAnimation: Bool

    
    @State var broadCasts = [BroadCastMessageModel]()
    var body: some View {
        let data = currentlyPresentedScheduleCard.currentlyShowing
        if !self.viewRendered {
            ProgressView().frame(width: 290, height: 250)
                .task {
                    FIRCloudImages.getImage(gsURL: data.images![0], eventID: data.FIRDocID!, eventDate: data.time) { image in
                        self.placeHolderUIImage = image!
                        self.viewRendered = true
                    }
                    
                    print("cache size", URLCache.shared.memoryCapacity / 1024)
                }
        } else {
            VStack(alignment: .leading) {
                ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                    if let imageLoaded = self.placeHolderUIImage {
                        Image(uiImage: imageLoaded)
                            .resizable()
                            .frame(height: 300)
                            .matchedGeometryEffect(id: "id", in: namespace, properties: .size)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    show.toggle()
                                }
                            }
                    }

                    HStack {
                        Button {
                            withAnimation(.spring()) {
                                show.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        Button {
                            let url = URL(string: "maps://?saddr=&daddr=\(data.coordinate.latitude),\(data.coordinate.longitude)")
                            if UIApplication.shared.canOpenURL(url!) {
                                UIApplication.shared.open(url!, options: [:], completionHandler: nil)
                            }
                        } label: {
                            Image(systemName: "location.north.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding()
                                .background(Color.white.opacity(0.85))
                                .clipShape(Circle())
                        }
                        Button(action: {
                            showingAlert = true
                        }) {
                            Image(systemName: "trash.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 20, height: 20)
                                .padding()
                                .foregroundColor(Color(.red))
                                .background(Color.white.opacity(0.7))
                                .clipShape(Circle())

                                
                        }.alert("Are you sure you want to delete the event?", isPresented: $showingAlert) {
                                Button("cancel", role: .cancel) { }
                                Button("delete", role: .destructive) {
                                    FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                    self.show = false
                                    self.toggleHeroAnimation = false
                                    
                                }
                            }
                    }
                    .padding(.top, 35)
                    .padding(.horizontal)
                }
                
                ScrollView(.vertical, showsIndicators: false) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(data.name)
                                .font(.title)
                                .fontWeight(.black)
                                .foregroundColor(.primary)
                            Text(data.category)
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                        }
                        Spacer()
                        Text(dateToString(date: data.time))
                    }
                    
                        VStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(height: 40)
                                .foregroundColor(.clear)
                                .overlay(
                                    Label {
                                        Text("Specific Instructions and Updates").bold()
                                    } icon: {
                                        Image(systemName: expandUpdates ? "chevron.down" : "chevron.right")
                                            .foregroundColor(.blue)
                                    }
                                    
                                )
                            VStack {
                                
                                ForEach(broadCasts, id: \.self) { msg in
                                    HStack {
                                        Text(msg.message)
                                        Spacer()
                                        Text(dateToString(date: msg.date))
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 10)
                                    .fixedSize(horizontal: false, vertical: true)
                                }
                                //                            .frame(width: UIScreen.main.bounds.width - 50)
                            }
                        }.background(GeometryReader {
                            Color.clear.preference(key: ViewHeightKey.self,
                                                   value: $0.frame(in: .local).size.height)
                        })
                        .onPreferenceChange(ViewHeightKey.self) { subviewHeight = $0 }
                        .frame(height: expandUpdates ? subviewHeight : 35, alignment: .top)
                        .padding()
                        .clipped()
                        .frame(maxWidth: UIScreen.main.bounds.width - 50)
                        .transition(.move(edge: .bottom))
                        .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)))
                        .onTapGesture {
                            withAnimation(.spring()) {
                                expandUpdates.toggle()
                            }
                        }
                        .cornerRadius(20)
                        
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(0..<(self.eventImages.count), id: \.self) { img in
                                    Group {
                                        if eventImages.count != 0 {
                                            Image(uiImage: eventImages[img])
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(10)
                                                .clipped()
                                        }
                                    }
                                }
                            }
                        }
                        
                        
                        Text(data.description)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .font(.subheadline)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 20)
                        
                    }
                    .padding()
                    
                    
//                }
                
                
            }.task {
                eventImages = []
                for imageURL in data.images! {
                    FIRCloudImages.getImage(gsURL: imageURL, eventID: data.FIRDocID!, eventDate: data.time) { image in
                        if(image!.size.height > 0 && image!.size.width > 0) {
                            eventImages.append(image!)
                        }
                    }
                }
                
                FirestoreCRUD().getBroadcast(eventID: data.FIRDocID!, eventCategory: data.category) { broadcasts in
                    if broadcasts != nil {
                        if broadcasts!.count != 0 {
                            self.broadCasts = broadcasts!
                        }
                        else {
                            self.broadCasts = [BroadCastMessageModel(message: "No new updates! Last checked:", date: Date())]
                        }
                        
                    }
                }
                
            }
        }
    }
    func dateToString(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd' 'HH:mm"
        let stringDate = dateFormatter.string(from: date)
        return stringDate
        
    }
}



struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
