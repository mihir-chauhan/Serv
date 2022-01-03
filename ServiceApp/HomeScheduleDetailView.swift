//
//  File.swift
//  ServiceApp
//
//  Created by mimi on 1/2/22.
//
import SwiftUI

struct HomeScheduleDetailView: View {
    var animation: Namespace.ID
    @Binding var toggleHeroAnimation: Bool
    var body: some View {
        if toggleHeroAnimation {
            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 20)
                .matchedGeometryEffect(id: "hero", in: animation)
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .foregroundColor(Color(.systemGray4))
                
                .onTapGesture {
                    withAnimation(.spring()) {
                    toggleHeroAnimation.toggle()
                    }
                }
            }
            Spacer()
                
                .edgesIgnoringSafeArea(.top)
            
        }
    }
}
