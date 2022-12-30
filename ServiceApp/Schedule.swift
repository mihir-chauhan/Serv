//
//  Schedule.swift
//  ServiceApp
//
//  Created by mimi on 12/29/21.
//

import SwiftUI
import MapKit

struct Schedule: View {
    @State private var data = EventInformationModel()
    @State private var eventDate = Date()

    @State private var showingDetailSheet = false
    
    @ObservedObject var results = FirestoreCRUD()
    @Namespace var animation
    
    var body: some View {
        NavigationView {
            ScrollView(.vertical, showsIndicators: false) {
                ForEach(results.allFIRResults, id: \.self) { event in
                    if (eventDate < event.time) {
//                        showing detail sheet???
//                        ScheduleCard(animation: animation, data: event, show: nil)
                    }
                }
            }
            
            .sheet(isPresented: $showingDetailSheet) {
                ScheduleCardDetailSheet(data: $data)
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
    
    func cardTapped(data: EventInformationModel) {
        self.data = data
        withAnimation(.spring()) {
            showingDetailSheet.toggle()
        }
    }
    
}
