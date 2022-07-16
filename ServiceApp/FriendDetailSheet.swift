//
//  FriendDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI
import SwiftUICharts

struct FriendDetailSheet: View {
    var data: UserInfoFromAuth
    @State var listOfEventsFriendIsGoing: [String] = []
    var body: some View {
        NavigationView {
            ScrollView {
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
                    Text(data.bio ?? "huhh no bio?").font(.system(.caption)).padding(5)
                    Spacer(minLength: 15)
                }
                
                Text("Attending Upcoming Events").font(.headline).bold()
                VStack(alignment: .leading) {
                    ForEach(self.listOfEventsFriendIsGoing, id: \.self) { event in
                        Text(event)
                            .padding(10)
//                            .cornerRadius(10)
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 10)
//                                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
//                            )
                    }
                }
                
//                Text("Email: \(data.email!)").font(.system(.caption)).padding(5)
                BarChartView(data: ChartData(points: [8,13,20,12,14,17,7,13,16]), title: "Service Hours per Week", legend: "Hours", form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, animatedToBack: true).padding(10)

                PieChartView(data: [8, 23, 54, 32], title: "Service Categories", form: ChartForm.extraLarge, dropShadow: false).padding(10)

            }
            .navigationTitle(data.displayName ?? "SMITHY?")
            .onAppear {
                FriendEventsInCommon().singularFriendEventRecognizer(uidFriend: "vPa8ksjZn2ht4Fvbt7YkqLCtIcX2") { events in
                    for event in events {
                        self.listOfEventsFriendIsGoing.append(event)
                        print("HEREt", event)
                    }

                }
            }
        }
    }

}
