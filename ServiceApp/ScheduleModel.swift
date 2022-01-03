//
//  ScheduleModel.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/3/22.
//

import SwiftUI

class ScheduleModel: ObservableObject {
    @Published var showDetail: Bool = false
    @Published var image: String?
    @Published var category: String?
    @Published var title: String?
    @Published var host: String?
    @Published var time: Date?
}
