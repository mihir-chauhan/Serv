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
            Image("leaderboardPic-1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 4, height: display.height / 4)
                .clipShape(Circle())
                .offset(y: display.height / 30)
            
            Image("leaderboardPic-2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 3, height: display.height / 3)
                .clipShape(Circle())
            
            Image("leaderboardPic-3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 4, height: display.height / 4)
                .clipShape(Circle())
                .offset(y: display.height / 30)
        }.padding()
        
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}
