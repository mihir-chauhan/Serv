//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sheetObserver = SheetObserver()
    @StateObject private var envVariablesForSettings = EnvironmentVariables()

    var body: some View {
        CustomTabBar()
            .environmentObject(sheetObserver)
            .environmentObject(envVariablesForSettings)
//            .preferredColorScheme(envVariablesForSettings.isDarkMode ? .dark : .light)
            .onAppear {
                FirebaseRealtimeDatabaseCRUD().writeFriends(for: "e001392e-9e9c-4672-83d0-099e4b8c455e", friendUUID: UUID().uuidString)
//                FirebaseRealtimeDatabaseCRUD().readEvents(for: "e001392e-9e9c-4672-83d0-099e4b8c455e") { eventsArray in
//                    var newArray = eventsArray
//                    newArray?.append(UUID().uuidString)
//                    ref.child("\("e001392e-9e9c-4672-83d0-099e4b8c455e"))/Events").setValue(newArray)
//                }
            }
        
    }
}
