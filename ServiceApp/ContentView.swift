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


extension Date {

    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }

    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var startOfDay: Date {
            return Calendar.current.startOfDay(for: self)
        }

        var endOfDay: Date {
            var components = DateComponents()
            components.day = 1
            components.second = -1
            return Calendar.current.date(byAdding: components, to: startOfDay)!
        }
}


// Try it
//let utcDate = Date().toGlobalTime()
//let localDate = utcDate.toLocalTime()
