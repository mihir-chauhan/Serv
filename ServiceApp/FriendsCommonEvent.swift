//
//  FriendsCommonEvent.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI

struct FriendsCommonEvent: View {
    var body: some View {
            HStack(spacing: -15) {
                Image("leaderboardPic-1")
                    .pfpIconModifier()
                Image("leaderboardPic-2")
                    .pfpIconModifier()
                Image("leaderboardPic-3")
                    .pfpIconModifier()
//                Image("leaderboardPic-1")
//                    .pfpIconModifier()
//                Image("leaderboardPic-2")
//                    .pfpIconModifier()
                
                // add to Socials page only, because we're reusing it in another view
//                Text("Common Event")
//                    .padding(.leading, 50)
//                    .font(.system(.caption))
                
            }.padding([.bottom, .horizontal], 10)
            
    }
}

struct FriendsCommonEvent_Previews: PreviewProvider {
    static var previews: some View {
        FriendsCommonEvent()
    }
}

extension Image {
    func pfpIconModifier() -> some View  {
        self
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: display.width / 8, height: display.width / 8)
            .scaleEffect(1.35)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 2))
    }
}
