//
//  ScheduleCardDetailView.swift
//  ServiceApp
//
//  Created by Kelvin J on 12/29/22.
//

import SwiftUI
import FirebaseAnalytics
import AlertToast

struct ScheduleCardDetailView: View {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var currentlyPresentedScheduleCard: CurrentlyPresentedScheduleCard
    //    var data: EventInformationModel
    @State var eventImages: [UIImage] = []
    @State var expandUpdates: Bool = false
    @State var expandInfo: Bool = false
    @State var subviewHeight : CGFloat = 0
    @State var infoSubviewHeight : CGFloat = 0
    @State var viewRendered = false
    @State var placeHolderUIImage: UIImage?
    @State var showingAlert = false
    @State var alertTitle = ""
    @State var organizationData: OrganizationInformationModel?
    
    @Namespace private var namespace
    @Binding var show: Bool
    @Binding var toggleHeroAnimation: Bool
    @Environment (\.colorScheme) var colorScheme: ColorScheme
    
    @State private var showSheet = false
    @State var reachedMaxSlotBool: Bool = false
    @State var buttonStateIsSignedUp: Bool = false

    @State var broadcasts = [BroadcastMessageModel]()
    
    var onRegister: (EventInformationModel) -> ()
    var onUnregister: (EventInformationModel) -> ()
    
    func checkForEventAdded(itemName: String) {
        FirebaseRealtimeDatabaseCRUD().readEvents(for: authViewModel.decodeUserInfo()!.uid) { eventsArray in
            if eventsArray == nil {
                buttonStateIsSignedUp = false
            } else {
                var i = 0
                while i < eventsArray!.count {
                    if eventsArray![i] == itemName {
                        buttonStateIsSignedUp = true
                        return
                    }
                    i += 1
                }
                buttonStateIsSignedUp = false
            }
        }
    }


    var body: some View {
        let data = currentlyPresentedScheduleCard.currentlyShowing
        let bookmark = currentlyPresentedScheduleCard.currentlyShowingBookmark
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
                            .scaledToFill()
                            .clipped()
                            .frame(width: UIScreen.main.bounds.size.width, height: 300)
                            .matchedGeometryEffect(id: "id", in: namespace, properties: .size)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    show.toggle()
                                }
                            }
                    }
                    
                    HStack {
                        Button {
                            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                            hapticResponse.impactOccurred()
                            withAnimation(.spring()) {
                                show.toggle()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.black.opacity(0.7))
                                .clipShape(Circle())
                        }
                        
                        Spacer()
                        Button {
                            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                            hapticResponse.impactOccurred()
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
                    }
                    .padding(.top, 55)
                    .padding(.horizontal)
                }
                
                ZStack {
                    (colorScheme == .dark ? Color.black : Color.white)
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
                            Text(data.time.dateToString())
                        }
                        
                        VStack {
                            RoundedRectangle(cornerRadius: 20)
                                .frame(height: 40)
                                .foregroundColor(.clear)
                                .overlay(
                                    HStack {
                                        Label {
                                            Text("Specific Instructions and Updates").bold()
                                        } icon: {
                                            Image(systemName: expandUpdates ? "chevron.down" : "chevron.right")
                                                .foregroundColor(colorScheme == .dark ? Color.white : Color.black)
                                        }
                                        Spacer()
                                    }
                                )
                            VStack {
                                
                                ForEach(broadcasts, id: \.self) { msg in
                                    HStack {
                                        Text(msg.message)
                                        Spacer()
                                        Text(msg.date.dateToString())
                                            .font(.caption)
                                    }
                                    .padding(.vertical, 10)
                                    .fixedSize(horizontal: false, vertical: true)
                                }
                            }
                        }.background(GeometryReader {
                            Color.clear.preference(key: ViewHeightKey.self,
                                                   value: $0.frame(in: .local).size.height)
                        })
                        .onPreferenceChange(ViewHeightKey.self) { subviewHeight = $0 }
                        .frame(height: expandUpdates ? subviewHeight : 35, alignment: .top)
                        .padding()
                        .clipped()
                        .transition(.move(edge: .bottom))
                        .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)))
                        
                        .onTapGesture {
                            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                            hapticResponse.impactOccurred()
                            withAnimation(.spring()) {
                                expandUpdates.toggle()
                            }
                        }
                        .cornerRadius(20)
                        
                        
                        OrganizationInfoCard(organizationData: $organizationData, expandInfo: $expandInfo)
                        
                        
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
                        
                        if bookmark {
                            if data.eventWebpage != nil {
                                Button(action: {
                                    showSheet.toggle()
                                }) {
                                    Capsule()
                                        .frame(width: 135, height: 45)
                                        .foregroundColor(.blue)
                                        .overlay(Label("**Register**", systemImage: "arrow.up.forward.app.fill").foregroundColor(.white).labelStyle(.titleAndIcon))
                                }
                            } else {
                                Button(action: {
                                    let responseHaptic = UIImpactFeedbackGenerator(style: .light)
                                    authViewModel.apnsToken = delegate.apnsToken
                                    FirebaseRealtimeDatabaseCRUD().updateApnsToken(uid: authViewModel.decodeUserInfo()!.uid, token: authViewModel.apnsToken)
                                    FirestoreCRUD().checkForMaxSlot(eventID: data.FIRDocID!, eventCategory: data.category) { reachedMaxSlots in
                                        if buttonStateIsSignedUp {
                                            FirestoreCRUD().RemoveFromAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, user_uuid: authViewModel.decodeUserInfo()!.uid)
                                            FirebaseRealtimeDatabaseCRUD().removeEvent(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                            buttonStateIsSignedUp = false
                                            
                                            responseHaptic.impactOccurred()
                                            alertTitle = "Unregistered"
                                            showingAlert.toggle()
                                            onUnregister(data)
                                        }
                                        else if !reachedMaxSlots && !buttonStateIsSignedUp {
                                            
                                            FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!, eventCategory: data.category, apnsToken: authViewModel.apnsToken)
                                            FirebaseRealtimeDatabaseCRUD().writeEvents(for: authViewModel.decodeUserInfo()!.uid, eventUUID: data.FIRDocID!)
                                            buttonStateIsSignedUp = true
                                            
                                            let parameters: [String : String] = [
                                                "event" : data.FIRDocID!,
                                                "user" : authViewModel.decodeUserInfo()!.uid
                                            ]
                                            Analytics.logEvent("event signed up", parameters: parameters)
                                            alertTitle = "Registered"
                                            showingAlert.toggle()
                                            responseHaptic.impactOccurred()
                                            onRegister(data)
                                        }
                                        else if reachedMaxSlots {
                                            reachedMaxSlotBool = true
                                        }
                                    }
                                    
                                }) {
                                    Capsule()
                                        .frame(width: 135, height: 45)
                                        .foregroundColor(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? .green : .red) : .gray)
                                        .overlay(Text(!reachedMaxSlotBool ? (!buttonStateIsSignedUp ? "Sign up" : "Remove Event") : "Reached Cap").foregroundColor(.white).bold())
                                }.disabled(reachedMaxSlotBool)
                            }
                        }
                    }
                    .padding()
                    
                }
                
                
            }
            .toast(isPresenting: $showingAlert) {
                AlertToast(type: .regular, title: alertTitle, subTitle: "It may take a moment to update")
            }
            .sheet(isPresented: $showSheet) {
                SheetView(webpage: data.eventWebpage!)
            }
            .task {
                checkForEventAdded(itemName: data.FIRDocID!)
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
                            self.broadcasts = broadcasts!
                        }
                        else {
                            self.broadcasts = [BroadcastMessageModel(message: "No new updates! Last checked:", date: Date())]
                        }
                        
                    }
                }
                FirestoreCRUD().getOrganizationDetail(ein: data.ein) { value in
                    organizationData = value!
                }
            }
        }
    }
}


private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
