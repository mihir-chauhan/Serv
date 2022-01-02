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
    var body: some View {
        NavigationView {
            ScrollView {
                if !self.fetchedResult.isEmpty {
                    
                        ForEach(self.fetchedResult) { event in
                            ScheduleCard(image: "community-service", category: event.category!, title: event.name!, host: event.host!, time: Date())
                                
                        }
//                        .onDelete(perform: {_ in
//                         CoreDataCRUD().deleteItems(offsets: T##IndexSet, events: T##FetchedResults<UserEvent>))
//                        })
                        
                }
                else {
                    Text("No events signed up!")
                }
//                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 1, 2022")
//
//                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 3, 2022")
//
//                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 5, 2022")
//
//                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 7, 2022")

            }
            .padding(.bottom, 60)
            .navigationTitle("Events Calendar")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    ZStack {
//                        DatePicker("Event Date", selection: $eventDate, in: Date()...)
//                            .datePickerStyle(GraphicalDatePickerStyle())
//                            .labelsHidden()
                        Image(systemName: "calendar.day.timeline.right")
//                            .resizable()
//                            .userInteractionDisabled()
                    }
                }
            }
        }
    }
}

struct Testing: ViewModifier {
    func body(content: Content) -> some View {
        SwiftUIWrapper { content }.allowsHitTesting(false)
    }
}

extension View {
    func userInteractionDisabled() -> some View {
        self.modifier(Testing())
    }
}

struct SwiftUIWrapper<T: View>: UIViewControllerRepresentable {
    let content: () -> T
    func makeUIViewController(context: Context) -> UIHostingController<T> {
        UIHostingController(rootView: content())
    }
    func updateUIViewController(_ uiViewController: UIHostingController<T>, context: Context) {}
}


struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}
