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
            Text("Good Evening")
                .font(.system(size: 25, weight: .bold, design: .default))
            
                .navigationTitle("Home")
        }
    }
}


struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
    }
}
