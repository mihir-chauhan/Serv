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
    @Binding var listOfEventsFriendIsGoing: [EventInformationModel]
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
                    }.padding(.bottom, 15)
                    
                    Text("\(data.displayName ?? "no name")'s Volunteered Hours (All-Time)").font(.headline).bold()
                    
                    LineGraph2(rawData: data.hoursSpent)
                        .frame(height: 220)
                        .padding(.bottom, 15)
                    
                    Text("\(data.displayName ?? "no name")'s Events").font(.headline).bold()
                    
                    ForEach(self.listOfEventsFriendIsGoing, id: \.self) { event in
                        Text("\t \(event.name)")
                            .padding(5)
                    }
                }.padding(20)
                    .navigationTitle(data.displayName ?? "no name")
            }
        }
    }
}
