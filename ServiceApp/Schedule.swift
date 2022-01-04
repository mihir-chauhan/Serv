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
    
    @State var PoI = pointsOfInterest
    var body: some View {
        NavigationView {
            ScrollView {
                if !self.fetchedResult.isEmpty {
                    
                    ForEach(0..<PoI.count, id: \.self) { event in
                            if (eventDate < PoI[event].time) {
                                // TODO: put code below in here after done testing
                            }
//                            ScheduleCard(image: "community-service", category: PoI[event].category, title: PoI[event].name, host: PoI[event].host, time: PoI[event].time, onTapCallback: self.cardTapped)
                        ScheduleCard(data: PoI[event], onTapCallback: self.cardTapped)
                        }
                        
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
