//
//  ScheduleCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 12/31/21.
//

import SwiftUI

struct ScheduleCard: View {
    var data: EventInformationModel
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
    
    var onTapCallback : (String, String, String, String, Date) -> ()
    
    var body: some View {
        Button {
            self.onTapCallback("community-service", data.category, data.name, data.host, data.time)
        } label: {
            VStack {
                // image can be removed later on if we dont want to have the host of the event add it
                ZStack {
                    Image("community-service")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                    VStack(alignment: .leading) {
                        HStack {
                            Spacer()
                            Button(action: {
                                //ADD EVENT
                            }) {
                                Image(systemName: "checkmark.circle.fill")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundColor(Color(.systemGray2))
                                    .padding(12)
                            }
                        }
                    }
                    
                }
                
                VStack(alignment: .leading) {
                    Text(data.category)
                        .font(.headline)
                        .foregroundColor(.secondary)
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
    }
}


struct CardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        return configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.easeIn, value: configuration.isPressed)
    }
}
