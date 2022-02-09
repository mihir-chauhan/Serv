//
//  ConfirmNewFriend.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/9/22.
//

import SwiftUI

struct ConfirmNewFriendView: View {
    @State var show = false
    var body: some View {
        Button(action: {
            show.toggle()
        }) {
            Text("toggle it")
        }
        if show {
        ConfirmNewFriend(show: $show)
        }
    }
}

struct ConfirmNewFriend: View {
    @Binding var show: Bool
    @State var animate = false
    var body: some View {
        ZStack {
            Image("community-service")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 300, height: 300)
        
        VStack {
            Circle()
                .stroke(AngularGradient(gradient: .init(colors: [Color.primary, Color.primary.opacity(0)]), center: .center))
                .frame(width: 80, height: 80)
                .rotationEffect(.init(degrees: animate ? 360 : 0))
            Text("Some text")
        }
        .padding(.vertical, 25)
        .padding(.horizontal, 35)
        .background(CustomMaterialEffectBlur())
        
        .background(Color.primary.opacity(0.25))
        .cornerRadius(20)
        .onTapGesture {
            withAnimation {
                show.toggle()
            }
        }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                animate.toggle()
            }
            
        }
    }
}

