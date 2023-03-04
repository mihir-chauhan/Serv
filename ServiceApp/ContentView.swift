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
    @StateObject private var locationVM = LocationTrackerViewModel()
    @StateObject private var authVM = AuthViewModel.shared
    @StateObject private var results = FirestoreCRUD()
    @StateObject private var currentlyPresentedScheduleCard = CurrentlyPresentedScheduleCard()
    @AppStorage("signInState", store: .standard) var signInState: AuthViewModel.SignInState = .signedOut
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    
    // dummy data for testing single views
    @State var data = EventInformationModel(id: UUID(), FIRDocID: "", name: "Trash Cleanup", host: "ABC Foundation", ein: "32-1263743", category: "Environmental", time: Date(), enterDetailView: true)
    var body: some View {
        VStack {
            if(!hasOnboarded) {
                OnboardingView(hasOnboarded: $hasOnboarded)
            } else {
                if (self.authVM.loading) {
                    ProgressView()
                } else {
                    switch self.signInState {
                    case .signedOut: AccountLoginView()
                    case .signedIn: CustomTabBar()
                    case .verificationPending: VerificationPending()
                    case .error: AccountLoginView()
                        
                    }
                }
            }
        }
        .environmentObject(tabBarController)
        .environmentObject(sheetObserver)
        .environmentObject(locationVM)
        .environmentObject(authVM)
        .environmentObject(results)
        .environmentObject(currentlyPresentedScheduleCard)
        .onChange(of: authVM.state) { newValue in
            self.signInState = newValue
        }
        .task {
            print("Not1stLaunch?", UserDefaults.standard.bool(forKey: "First_Launch"))
            if(!UserDefaults.standard.bool(forKey: "First_Launch")) {
                authVM.signOut()
                UserDefaults.standard.setValue(true, forKey: "First_Launch")
                results.queryAllCategories(resetAllToTrue: true)
            }
        }
    }
}
