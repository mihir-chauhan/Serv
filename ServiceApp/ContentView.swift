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
//    @AppStorage("currentUser", store: .standard) var currentUser: String?
    @State var data = EventInformationModel(id: UUID(), FIRDocID: "", name: "Trash Cleanup", host: "ABC Foundation", ein: "32-1263743", category: "Environmental", time: Date(), enterDetailView: true)
    var body: some View {
        VStack {
            switch self.signInState {
            case .signedOut: AccountLogin2()
            case .signedIn: CustomTabBar()
            case .error: AccountLogin2()            }
        }
//        ScheduleCardDetailSheet(data: $data)

        .environmentObject(sheetObserver)
        .environmentObject(viewModel)
        .onChange(of: viewModel.state) { newValue in
            self.signInState = newValue
        }
    }
}
