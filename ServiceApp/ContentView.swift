//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var sheetObserver = SheetObserver()
    @StateObject private var signInState = EPAuthViewModel()
    @StateObject var viewModel = AuthViewModel()
    var body: some View {
        VStack {
            switch viewModel.state {
            case .signedOut: SignInView()
            case .signedIn: CustomTabBar()
            case .error: Text("Error")
            }
        }
        .environmentObject(sheetObserver)
        .environmentObject(signInState)
        .environmentObject(viewModel)

    }
}
