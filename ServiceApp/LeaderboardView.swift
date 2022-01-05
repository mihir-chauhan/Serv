//
//  LeaderboardView.swift
//  ServiceApp
//
//  Created by mimi on 1/3/22.
//

import SwiftUI

struct LeaderboardView: View {
//    @State var startAnimationDelay: Bool = false
    var body: some View {
        HStack {
            VStack {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.4745098039, green: 0.4745098039, blue: 0.4745098039, alpha: 1)), Color(#colorLiteral(red: 0.7725490196, green: 0.7725490196, blue: 0.7725490196, alpha: 1)), Color(#colorLiteral(red: 0.8078431373, green: 0.8078431373, blue: 0.8078431373, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(Circle()
                                .strokeBorder(lineWidth: 3)
                                .frame(width: display.width / 4)
                        )
                Image("leaderboardPic-1")
                    .resizable()
                    .modifier(LeaderboardIconModifier(frameDivdedBy: 5))
                }
//                .animation(.easeIn(duration: 0.1).delay(0.1))
                Text("Bunny?")
                    .font(.system(.caption))
                    
            }
            .offset(y: display.height / 30)
            
            VStack {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 1, green: 0.7058823529, blue: 0.01568627451, alpha: 1)), Color(#colorLiteral(red: 0.9882352941, green: 0.7607843137, blue: 0.003921568627, alpha: 1)), Color(#colorLiteral(red: 1, green: 0.968627451, blue: 0.4784313725, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(Circle()
                                .strokeBorder(lineWidth: 3)
                                .frame(width: display.width / 3, height: display.height / 3)
                        )
                        
                    
                Image("leaderboardPic-2")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: display.width / 3.5)
                    .scaleEffect(1.05)
                    .clipShape(Circle())
                    .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: -5)
                    .shadow(color: Color.white.opacity(0.7), radius: 10, x: 5, y: 5)
                }
                Text("Kelvin and Hobbes")
                    .font(.system(.caption))
                    .padding(.top, 10)
            }
            
            
            VStack {
                ZStack {
                    LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.5019607843, green: 0.2901960784, blue: 0, alpha: 1)), Color(#colorLiteral(red: 0.537254902, green: 0.368627451, blue: 0.1019607843, alpha: 1)), Color(#colorLiteral(red: 0.6901960784, green: 0.5529411765, blue: 0.3411764706, alpha: 1))]), startPoint: .topLeading, endPoint: .bottomTrailing)
                        .mask(Circle()
                                .strokeBorder(lineWidth: 3)
                                .frame(width: display.width / 4)
                        )
                Image("leaderboardPic-3")
                    .resizable()
                    .modifier(LeaderboardIconModifier(frameDivdedBy: 5))
                }
//                .animation(.easeIn(duration: 0.1).delay(0.2))
                
                Text("Day6")
                    .font(.system(.caption))
                    
            }
            .offset(y: display.height / 30)
        }.padding(.vertical, 10)
//        .onAppear {
//
//        }
    }
}

struct LeaderboardView_Previews: PreviewProvider {
    static var previews: some View {
        LeaderboardView()
    }
}

struct LeaderboardIconModifier: ViewModifier {
    var frameDivdedBy: CGFloat
    func body(content: Content) -> some View {
        content
            .aspectRatio(contentMode: .fit)
            .frame(width: display.width / self.frameDivdedBy)
            .scaleEffect(1.05)
            .clipShape(Circle())
            .shadow(color: Color.black.opacity(0.2), radius: 10, x: -5, y: -5)
            .shadow(color: Color.white.opacity(0.7), radius: 10, x: 5, y: 5)
    }
}
