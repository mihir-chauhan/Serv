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
    @StateObject private var signInState = AuthViewModel()
    var body: some View {
//        CustomTabBar()
//        SignIn()
        AuthViewManager()
            .environmentObject(sheetObserver)
            .environmentObject(envVariablesForSettings)
            .environmentObject(signInState)
            .onAppear {
                
            }
    }
}
