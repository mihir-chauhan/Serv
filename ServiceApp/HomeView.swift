//
//  HomeView.swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .trailing) {
                    PVSAProgressBar()
                    Text("46 more hours to go...")
                        .font(.caption)
                }
                //                Your upcoming events
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: UIScreen.main.bounds.width - 40, height: 125)
                    .foregroundColor(Color(.systemGray4))
                VStack(alignment: .leading) {
                    Text("Categories")
                        .font(.system(.headline))
                        .padding(.leading, 10)
                    HStack {
                        ForEach(0..<4, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 50)
                                .frame(width: 75, height: 75)
                                .foregroundColor(Color(.systemGray4))
                                .overlay(Text("🌲").font(.system(size: 30)))
                        }.padding(10)
                    }
                    Text("Recommended")
                        .font(.system(.headline))
                        .padding(.leading, 10)
                    HStack {
                        ForEach(0..<2, id: \.self) { _ in
                            ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 180, height: 250)
                                    .foregroundColor(Color(#colorLiteral(red: 0.9688304554, green: 0.9519491526, blue: 0.8814709677, alpha: 1)))
                                RoundedRectangle(cornerRadius: 20)
                                    .frame(width: 180, height: 145)
                                    .foregroundColor(Color(.systemGray4))
                            }
                            
                        }.padding(10)
                    }
                    Text("Friend Activity")
                        .font(.system(.headline))
                        .padding(.leading, 10)
                }
                
                
                Spacer()
                
            }.padding(.vertical)
            
            
            .navigationTitle("Home")
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
