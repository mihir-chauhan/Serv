//
//  ContentView.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI
import GoogleSignIn

struct ContentView: View {
    @StateObject private var sheetObserver = SheetObserver()
    @StateObject var viewModel = AuthViewModel()
    @AppStorage("signInState", store: .standard) var signInState: AuthViewModel.SignInState = .signedOut
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
//    @AppStorage("currentUser", store: .standard) var currentUser: String?
    @State var data = EventInformationModel(id: UUID(), FIRDocID: "", name: "Trash Cleanup", host: "ABC Foundation", ein: "32-1263743", category: "Environmental", time: Date(), enterDetailView: true)
    var body: some View {
        VStack {
            switch hasOnboarded {
            case false:
                OnboardingView()
            case true:
                switch self.signInState {
                case .signedOut: AccountLoginView()
                case .signedIn: CustomTabBar()
                case .error: AccountLoginView()
                }
            }
        }
        .onAppear {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let startEventDate: Date? = dateFormatter.date(from: "2022-07-15")
            let endEventDate: Date? = dateFormatter.date(from: "2022-07-16")
            FirestoreCRUD().sortGivenDateRange(startEventDate: startEventDate!, endEventDate: endEventDate!)
        }


        .environmentObject(sheetObserver)
        .environmentObject(viewModel)
        .onChange(of: viewModel.state) { newValue in
            self.signInState = newValue
        }
    }
}
