//
//  FriendsCommonEvent.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI

struct FriendsCommonEvent: View {
    var imgArray = ["leaderboardPic-1", "leaderboardPic-2", "leaderboardPic-3", "img", "img4", "img2", "person", "community-service"]
    var img1Name = ""
    var img2Name = ""
    var img3Name = ""

    init() {
        let firstChoice = Int.random(in: 0..<imgArray.count)
        img1Name = imgArray[firstChoice]
        imgArray.remove(at: firstChoice)
        
        
        let secondChoice = Int.random(in: 0..<imgArray.count)
        img2Name = imgArray[secondChoice]
        imgArray.remove(at: secondChoice)
        
        
        let thirdChoice = Int.random(in: 0..<imgArray.count)
        img3Name = imgArray[thirdChoice]
        imgArray.remove(at: thirdChoice)
    }
    
    var body: some View {
            HStack(spacing: -15) {
                Image(img1Name)
                    .pfpIconModifier()
                Image(img2Name)
                    .pfpIconModifier()
                Image(img3Name)
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
