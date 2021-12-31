//
//  EventDetailView .swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    var data: EventInformationModel = EventInformationModel()
    @Binding var sheetMode: SheetMode
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(data.name)
                    .font(.system(size: 30))
                    .fontWeight(.bold)
                Spacer()
                Button(action: {
                    self.sheetMode = .quarter
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.systemGray2))
                        .padding(12)
                }
            }
            
            VStack(alignment: .leading) {
                Text("Environmental")
                    .font(.system(.headline))
                    .foregroundColor(.gray)
                //            use dateFormatter here
                Text("\(data.time)")
            }.padding()
            Spacer()
                
            
        }
        .padding()

    }
}

struct EventInformationModel: Identifiable {
    
    var id = UUID()
    var name: String = "Event Name"
    var category: String = ""
    var time: Date = Date()
    var description: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat."
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    var enterDetailView: Bool = false
}
