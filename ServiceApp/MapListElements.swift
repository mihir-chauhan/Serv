//
//  MapListElements.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct MapListElements: View {
//    @State var detailView: EventInformationModel
    @Binding var sheetMode: SheetMode
    @State var text = ""
    

    var body: some View {
        ZStack {
        VStack(alignment: .leading) {
            Text("Events")
                .font(.system(size: 35))
                .fontWeight(.bold)
                .padding()
            HStack {
                HStack {
                    TextField("Search Events...", text: $text)
                    if !text.isEmpty {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.systemGray2))
                            .padding(.horizontal, 3)
                            .onTapGesture {
                                self.text = ""
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
            
            List(0..<pointsOfInterest.count, id: \.self) { event in
                #warning("lead to detail view")
                Button(action: {
                    withAnimation(.spring()) {
                        self.sheetMode = .half
                        pointsOfInterest[event].enterDetailView.toggle()
                    }
                }) {
                    Text(pointsOfInterest[event].name)
                        
                }.padding(.vertical)
            }.padding(.vertical)
            
        }
            CloseButton(sheetMode: $sheetMode)
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
