//
//  LeaderboardView.swift
//  ServiceApp
//
//  Created by mimi on 1/3/22.
//

import SwiftUI

struct LeaderboardView: View {
    var body: some View {
        HStack {
            VStack {
                Image("leaderboardPic-1")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: display.width / 4)
                    .scaleEffect(1.05)
                    .clipShape(Circle())
                    .offset(y: display.height / 30)
                Text("Bunny?")
                    .font(.system(.caption))
                    .offset(y: display.height / 30)
            }
            
            
            VStack {
                Image("leaderboardPic-2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: display.width / 3)
                    .scaleEffect(1.05)
                    .clipShape(Circle())
                Text("Kelvin and Hobbes")
                    .font(.system(.caption))
            }
            
            
            VStack {
                Image("leaderboardPic-3")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: display.width / 4)
                    .scaleEffect(1.35)
                    .clipShape(Circle())
                    .offset(y: display.height / 30)
                Text("Day6")
                    .font(.system(.caption))
                    .offset(y: display.height / 30)
            }
        }.padding()
        
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
