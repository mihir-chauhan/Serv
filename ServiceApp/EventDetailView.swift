//
//  EventDetailView .swift
//  ServiceApp
//
//  Created by mimi on 12/26/21.
//

import SwiftUI
import MapKit

struct EventDetailView: View {
    @FetchRequest(entity: UserEvent.entity(), sortDescriptors: []) public var fetchedResult: FetchedResults<UserEvent>
    var data: EventInformationModel = EventInformationModel()
    var coreDataCRUD = CoreDataCRUD()
    @Binding var sheetMode: SheetMode
    var dateToString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            let stringDate = dateFormatter.string(from: data.time)
            return stringDate
        }
    }
    func checkForEventAdded(itemName: String) -> Bool {
        for i in self.fetchedResult {
            if i.name == itemName {
                return true
            }
        }
        return false
    }
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
                Text(data.category)
                    .font(.system(.headline))
                    .foregroundColor(.gray)
                Text(self.dateToString)
                ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                        ForEach(0..<5, id: \.self) { img in
                            RoundedRectangle(cornerRadius: 15)
                                .frame(width: 135, height: 135)
                                .foregroundColor(.gray)
                        }
                    }
                }
                Text(data.description)
                    .font(.caption)
            }
            HStack {
                Spacer()
                Button(action: {
                    CoreDataCRUD().addUserEvent(name: data.name, category: data.category, host: data.host, time: data.time)
                    FirestoreCRUD().AddToAttendeesList(eventID: data.FIRDocID!)
                    FirebaseRealtimeDatabaseCRUD().writeEvents(for: user_uuid, eventUUID: data.FIRDocID!)
                    self.sheetMode = .quarter
                }) {
                Capsule()
                    .frame(width: 135, height: 45)
                    .foregroundColor(checkForEventAdded(itemName: data.name) ? .gray : .blue)
                    .overlay(Text("Add to Saved").foregroundColor(.white))
                }.disabled(checkForEventAdded(itemName: data.name) ? true : false)
            }
            .padding(.vertical, 30)
            .padding(.horizontal, 15)
            Spacer()
        }
        .padding()
    }
}
