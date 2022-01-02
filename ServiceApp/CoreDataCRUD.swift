//
//  CoreDataCRUD.swift
//  ServiceApp
//
//  Created by mimi on 1/1/22.
//

import CoreData
import SwiftUI

class CoreDataCRUD {
    let viewContext = PersistenceController.shared.container.viewContext

    func addUserEvent(name: String, category: String, host: String, time: Date) {
        let newEvent = UserEvent(context: viewContext)
        newEvent.name = name
        newEvent.category = category
        newEvent.host = host
        newEvent.time = time
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func fetchUserEvent() {
        do {
            try viewContext.fetch(UserEvent.fetchRequest())
        } catch {
            fatalError()
        }
    }
    
    func deleteItems(offsets: IndexSet, events: FetchedResults<UserEvent>) {
        withAnimation {
            offsets.map { events[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
}

