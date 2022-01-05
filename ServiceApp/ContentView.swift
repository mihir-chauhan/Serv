//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject var sheetObserver = SheetObserver()
    @StateObject private var cardData = ScheduleModel()

    var body: some View {
        PhotoPicker()
//        CustomTabBar()
//        FriendDetailSheet(name: "me")
//        LeaderboardView()
            .environmentObject(sheetObserver)
            .environmentObject(cardData)
        
    }
}
