//
//  Schedule.swift
//  ServiceApp
//
//  Created by mimi on 12/29/21.
//

import SwiftUI

struct Schedule: View {
    @FetchRequest(entity: UserEvent.entity(), sortDescriptors: []) public var fetchedResult: FetchedResults<UserEvent>
    @State private var eventDate = Date()
    @State private var image: String = "coummunity-service"
    @State private var category: String = "Environmental"
    @State private var title: String = "Event Name"
    @State private var host: String = "Host"
    @State private var time: Date = Date()

    @EnvironmentObject var cardData: ScheduleModel
    @Namespace var animation
    
    var body: some View {
        NavigationView {
            ScrollView {
                if !self.fetchedResult.isEmpty {
                    
                        ForEach(self.fetchedResult) { event in
                            if (eventDate < event.time!) {
                                // TODO: put code below in here after done testing
                            }
                            ScheduleCard(image: "community-service", category: event.category!, title: event.name!, host: event.host!, time: event.time!, onTapCallback: self.cardTapped)
                        }
//                        .onDelete(perform: {_ in
//                         CoreDataCRUD().deleteItems(offsets: T##IndexSet, events: T##FetchedResults<UserEvent>))
//                        })
                        
                }
                else {
                    Text("No events signed up!")
                }
            }
            .padding(.bottom, 60)
            .navigationTitle("Events Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DatePicker("Event Date", selection: $eventDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .frame(width: 75, alignment: .trailing)
                }
            }
            .overlay(
                EventDetailSheet(animation: animation).environmentObject(cardData)
            )
            
        }
    }
    
    func cardTapped(image: String, category: String, title: String, host: String, time: Date) {

        withAnimation(.spring()) {
            cardData.image = image
            cardData.category = category
            cardData.title = title
            cardData.host = host
            cardData.time = time
            cardData.showDetail = true
        }
//        showingSheet.toggle()
    }

}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}
