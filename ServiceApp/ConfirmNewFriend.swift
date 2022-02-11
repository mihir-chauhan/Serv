//
//  ConfirmNewFriend.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/9/22.
//

import SwiftUI

struct ConfirmNewFriendView: View {
    @Binding var show: Bool
    @State private var downloadButtonTapped = false
    @State private var loading = false
    @State private var fullcircle = false
    @State private var completed = false
    var body: some View {
        if show {
        ZStack {
            RoundedRectangle(cornerRadius: 30)
                .trim(from: 0, to: self.fullcircle ? 0.95 : 1)
                .stroke(lineWidth: 5)
                .frame(width: self.downloadButtonTapped ? 60 : 300, height: 60)
                .foregroundColor(self.downloadButtonTapped ? .purple : Color(red: 230/255, green: 230/255, blue: 230/255))
            
                .background(self.downloadButtonTapped ? Color.primary.opacity(0.25) : Color(red: 230/255, green: 230/255, blue: 230/255))
                
                .cornerRadius(30)
                .rotationEffect(Angle(degrees: self.loading ? 0 : -1440))
            
            if !downloadButtonTapped {
                HStack {
                    Image("riding").resizable().frame(width: 30, height: 30)
                    Text("Enter")
                }
                .font(.headline)
                .onDisappear() {
                    self.startProcessing()
                }
            }
            
            if completed {
                VStack {
                CheckMarkAnimation()
                    .foregroundColor(.purple)
                Text("Friend Added!")
                }.offset(x: -5, y: 9)
            }
        }
        .padding(.vertical, 50)
            .padding(.horizontal, 50)
            .background(CustomMaterialEffectBlur())
            
            .background(Color.primary.opacity(0.25))
            .cornerRadius(20)
            .onAppear {
                withAnimation(.default) {
                    self.downloadButtonTapped = true
                    self.fullcircle = true
                }
            }
        }
    }
    private func startProcessing() {
        withAnimation(Animation.linear(duration: 5)) {
            self.loading = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation {
            self.completed = true
            self.fullcircle = false
            }
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

struct CheckMarkAnimation: View {
    @State var checkViewAppear = false
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let width: CGFloat = min(geo.size.width, geo.size.height)
                let height = geo.size.height
                
                path.addLines([
                    .init(x: width/2 - 10, y: height/2 - 10),
                    .init(x: width/2, y: height/2),
                    .init(x: width/2 + 20, y: height/2 - 20)
                ])
            }
            .trim(from: 0, to: checkViewAppear ? 1 : 0)
            .stroke(style: StrokeStyle(lineWidth: 2.0, lineCap: .round))
            .frame(width: 50, height: 50)
            .aspectRatio(1, contentMode: .fit)
            .onAppear {
                self.checkViewAppear.toggle()
            }
        }.frame(width: 50, height: 50)
            
    }
}
