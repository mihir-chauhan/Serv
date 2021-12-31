//
//  Schedule.swift
//  ServiceApp
//
//  Created by mimi on 12/29/21.
//

import SwiftUI

struct Schedule: View {
    var body: some View {
        NavigationView {
            ScrollView {
                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 1, 2022")
                
                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 3, 2022")
                
                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 5, 2022")
                
                ScheduleCard(image: "community-service", category: "Environmental", title: "My Service", host: "January 7, 2022")

            }
            .padding(.bottom, 60)
            .navigationTitle("Schedule")
        }
    }
}

struct Schedule_Previews: PreviewProvider {
    static var previews: some View {
        Schedule()
    }
}
