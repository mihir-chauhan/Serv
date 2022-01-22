//
//  ServiceAppApp.swift
//  ServiceApp
//
//  Created by mimi on 12/23/21.
//

import SwiftUI
import Firebase

@main
struct ServiceAppApp: App {
    let persistenceController = PersistenceController.shared
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
