//
//  FriendCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI

struct FriendCardView: View {
    var image: String
    var lastService: String
    var name: String

    var body: some View {
        HStack {
            Image(image)
                .resizable()
                .scaledToFill()
                .frame(width: 65, height: 65)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .clipped()
                .padding(.leading, 6.5)

            HStack {
                VStack(alignment: .leading) {
                    Text("Last Service: " + lastService + " hrs ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(name)
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.primary)
                    
                }

                Spacer()
            }
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
