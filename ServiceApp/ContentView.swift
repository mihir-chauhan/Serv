//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @StateObject private var tabBarController = TabBarController()
    @StateObject private var sheetObserver = SheetObserver()
    @StateObject private var mapViewModel = LocationTrackerViewModel()
    @StateObject private var viewModel = AuthViewModel()
    @AppStorage("signInState", store: .standard) var signInState: AuthViewModel.SignInState = .signedOut
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @State var data = EventInformationModel(id: UUID(), FIRDocID: "", name: "Trash Cleanup", host: "ABC Foundation", ein: "32-1263743", category: "Environmental", time: Date(), enterDetailView: true)
    var body: some View {
        VStack {
            if(!hasOnboarded) {
                OnboardingView(hasOnboarded: $hasOnboarded)
            } else {
                switch self.signInState {
                case .signedOut: AccountLoginView()
                case .signedIn: CustomTabBar()
                case .error: AccountLoginView()
                }
            }
        }
        .environmentObject(tabBarController)
        .environmentObject(sheetObserver)
        .environmentObject(mapViewModel)
        .environmentObject(viewModel)
        .onChange(of: viewModel.state) { newValue in
            self.signInState = newValue
        }
    }
}
