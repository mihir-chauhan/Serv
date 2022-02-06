//
//  Schedule.swift
//  ServiceApp
//
//  Created by mimi on 12/29/21.
//

import SwiftUI

struct Schedule: View {
    @State private var eventDate = Date()
    @State private var image: String = "coummunity-service"
    @State private var category: String = "Environmental"
    @State private var title: String = "Event Name"
    @State private var host: String = "Host"
    @State private var time: Date = Date()
    
    @State private var showingDetailSheet = false
    
    @ObservedObject var results = FirestoreCRUD()
    @Namespace var animation
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(results.allFIRResults, id: \.self) { event in
                    if (eventDate < event.time) {
                        ScheduleCard(data: event, onTapCallback: self.cardTapped)
                    }
                }
            }
            
            
            
            .padding(.bottom, 80)
            .navigationTitle("Events Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    DatePicker("Event Date", selection: $eventDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                        .frame(width: 75, alignment: .trailing)
                }
            }
        }
    }
    
    func cardTapped(image: String, category: String, title: String, host: String, time: Date) {
        self.title = title
        withAnimation(.spring()) {
            print("pnaslfjnasldkjfnl")
            showingDetailSheet.toggle()
        }
    }
    
}
