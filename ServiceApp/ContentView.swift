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
            case .signedOut: AccountLogin2()
            case .signedIn: CustomTabBar()
            case .error: Text("Error")
            }
        }
//        CustomTabBar()
//        HostViewAllEvents()
//        AccountLogin2()
        .environmentObject(sheetObserver)
        .environmentObject(viewModel)
        .onChange(of: viewModel.state) { newValue in
            self.signInState = newValue
        }
//            FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { value in
//                print("KEY BVALUE", value.keys, value.values)
//            FirebaseRealtimeDatabaseCRUD().getUserFriends(uid: (viewModel.decodeUserInfo()?.uid)!) { value in
//                for i in value {
//                    print("HERE", i)
//                }
//            }
//        }
    }
}
