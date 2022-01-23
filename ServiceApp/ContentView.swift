//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sheetObserver = SheetObserver()
    @StateObject private var cardData = ScheduleModel()
    @StateObject private var envVariablesForSettings = EnvironmentVariables()

    var body: some View {
        CustomTabBar()
            .environmentObject(sheetObserver)
            .environmentObject(cardData)
            .environmentObject(envVariablesForSettings)
        
            .preferredColorScheme(envVariablesForSettings.isDarkMode ? .dark : .light)
        
    }
}
