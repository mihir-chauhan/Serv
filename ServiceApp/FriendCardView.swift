//
//  FriendCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI

struct FriendCardView: View {
    
    var image: URL
    var lastService: String
    var name: String
    var onTapCallback : (String, URL) -> ()

    var body: some View {
        Button {
            self.onTapCallback(name, image)
        } label: {
            HStack {
                AsyncImage(url: image) { img in
                    img
                        .resizable()
                        .scaledToFill()
        
                } placeholder: {
                    Color.gray
                }
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 65, height: 65)
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
            .padding([.top, .horizontal], 5)
        }
//        .buttonStyle(CardButtonStyle())
    }
}
