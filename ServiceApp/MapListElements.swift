//
//  MapListElements.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct MapListElements: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var searchTerm = ""
    @Binding var eventPresented: EventInformationModel

    var body: some View {
        ZStack {
        VStack(alignment: .leading) {
            Text("Events")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .padding()
            HStack {
                HStack {
                    TextField("Search Events...", text: $searchTerm)
                    if !searchTerm.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.systemGray2))
                            .padding(.horizontal, 3)
                            .onTapGesture {
                                self.searchTerm = ""
                            }
                    }
                }.padding(10)
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                
                Button(action: { }) {
                    
                    RoundedRectangle(cornerRadius: 10)
                                .frame(width: 40, height: 40)
                                .foregroundColor(.white)
                        .overlay(
                            Image("funnel")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundColor(Color(#colorLiteral(red: 0.9490196078, green: 0.968627451, blue: 0.9725490196, alpha: 1)))
                        )
                    
                }
            }.padding(.top, 10)
            .padding(.horizontal, 20)
            if self.searchTerm.isEmpty {
                List(0..<pointsOfInterest.count, id: \.self) { event in
                    Button(action: {
                        withAnimation(.spring()) {
//                            self.eventPresented = pointsOfInterest[event]
//                              self.sheetMode = .half
                            self.sheetObserver.eventDetailData = pointsOfInterest[event]
                            self.sheetObserver.sheetMode = .half
                        }
                    }) {
                        ListCellView(event: pointsOfInterest[event])
                        
                    }.padding(.vertical)
                }.padding(.vertical)
            }
            else {
                List(pointsOfInterest.filter({$0.name.localizedCaseInsensitiveContains(searchTerm)})) { event in
                    Button(action: {
                        withAnimation(.spring()) {
                            self.sheetObserver.eventDetailData = event
                            self.sheetObserver.sheetMode = .half

                        }
                    }) {
                        ListCellView(event: event)
                        
                    }.padding(.vertical)
                }.padding(.vertical)
            }
        }
            CloseButton(sheetMode: $sheetObserver.sheetMode)
        }
    }
}

struct ListCellView: View {
    var event: EventInformationModel
    var body: some View {
        HStack {
            Text(event.name)
            Spacer(minLength: 10)
            Text("4.0 miles away")
                .font(.caption)
        }
    }
    
}

struct CloseButton: View {
    @Binding var sheetMode: SheetMode
    var body: some View {
        VStack {
            HStack {
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
            .padding(.top, 5)
            Spacer()
        }
    }
}
