//
//  FriendDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI
import SwiftUICharts

struct FriendDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var sheetObserver: SheetObserver
    var data: UserInfoFromAuth
    @State var listOfEventsFriendIsGoing: [EventInformationModel] = []
    @State var clickOnEvent: Bool = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading) {
                HStack {
                    AsyncImage(url: data.photoURL) { img in
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                    }
                        
                        .frame(width: display.width / 4)
                        .scaleEffect(1.1)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                    Text(data.bio ?? "No Bio").font(.system(.caption)).padding(5)
                    Spacer(minLength: 15)
                }
//                BarChartView(data: ChartData(points: [8,13,20,12,14,17,7,13,16]), title: "Service Hours per Week", legend: "Hours", form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, animatedToBack: true)
                    let _ = print("39", data.hoursSpent)
                    PVSALineGraph(data: data.hoursSpent, user: data.uid!)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                        )
                        
                    
                    Text("Attending Upcoming Events").font(.headline).bold()

                        ForEach(self.listOfEventsFriendIsGoing, id: \.self) { event in
                            Text("\t \(event.name)")
                                .padding(5)
                        }
                }.padding(20)
            .navigationTitle(data.displayName ?? "SMITHY?")
            
            .task {
                FriendEventsInCommon().singularFriendEventRecognizer(uidFriend: data.uid) { events in
                    for event in events {
                        FirestoreCRUD().getSpecificEvent(eventID: event) { eventName in
                            self.listOfEventsFriendIsGoing.append(eventName)
                        }

                        print("HEREt", event)
                    }
                }
                }
            }
        }
    }

}


extension View {
    /// Navigate to a new view.
    /// - Parameters:
    ///   - view: View to navigate to.
    ///   - binding: Only navigates when this condition is `true`.
    func navigate<NewView: View>(to view: NewView, when binding: Binding<Bool>) -> some View {
        NavigationView {
            ZStack {
                self
                    .navigationBarTitle("")
                    .navigationBarHidden(true)

                NavigationLink(
                    destination: view
                        .navigationBarTitle("")
                        .navigationBarHidden(true),
                    isActive: binding
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
    }
}
