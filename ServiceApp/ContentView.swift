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


    var body: some View {
        VStack {
            switch self.signInState {
            case .signedOut: SignInView()
            case .signedIn: CustomTabBar()
            case .error: Text("Error")
            }
        }
        .environmentObject(sheetObserver)
        .environmentObject(viewModel)
        .onChange(of: viewModel.state) { newValue in
            self.signInState = newValue
        }
    }
}
