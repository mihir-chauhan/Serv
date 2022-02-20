//
//  ServiceAppApp.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI
import Firebase
import GoogleSignIn

@main
struct ServiceAppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
//    @EnvironmentObject private var appDelegate: AppDelegate
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, option: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
