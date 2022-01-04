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
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 8)
                .scaleEffect(1.35)
                .clipShape(Circle())
            Image("leaderboardPic-2")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 8)
                .scaleEffect(1.35)
                .clipShape(Circle())
            Image("leaderboardPic-3")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: display.width / 8)
                .scaleEffect(1.35)
                .clipShape(Circle())
            
            Text("Common Event")
                .padding(.leading, 25)
	       .font(.system(.caption))

        }
    }
}

struct FriendsCommonEvent_Previews: PreviewProvider {
    static var previews: some View {
        FriendsCommonEvent()
    }
}
