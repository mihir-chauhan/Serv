//
//  ScheduleCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 12/31/21.
//

import SwiftUI

struct ScheduleCard: View {
    var image: String
    var category: String
    var title: String
    var host: String
    var time: Date
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
    var body: some View {
        VStack {
            // image can be removed later on if we dont want to have the host of the event add it
            Image(image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                
            HStack {
                VStack(alignment: .leading) {
                    Text(category)
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text(title)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                        //.lineLimit(3) maybe we dont need it...maybe we dooo?
                    Text(time, formatter: dateFormatter)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                }
                .layoutPriority(100)

                Spacer()
            }
            .padding()
        }
        .contextMenu(ContextMenu(menuItems: {
            Button(action: { }) { Text("View") }
            Button(action: { }) {
                Text("Delete Event")
                    .foregroundColor(.red)
            }
        }))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
        )
        .padding([.top, .horizontal])
    }
}
