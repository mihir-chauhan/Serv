//
//  ScheduleCardView.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 12/31/21.
//

import SwiftUI

struct ScheduleOverlayDescriptionCard: View {
    var dateToString: String = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd-yyy"
        let stringDate = dateFormatter.string(from: Date())
        return stringDate
    }()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    
    var body: some View {
        Button {
            print("akjdfnkla")
        } label: {
            
        }
        .buttonStyle(CardButtonStyle())
    }
}
