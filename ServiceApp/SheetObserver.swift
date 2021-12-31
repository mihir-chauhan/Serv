//
//  CustomModalReading.swift
//  ServiceApp
//
//  Created by mimi on 12/29/21.
//

import SwiftUI

class SheetObserver: ObservableObject {
    @Published var sheetMode: SheetMode = .quarter

    func toFullSheet() {
        self.sheetMode = .full
    }
    func toHalfSheet() {
        self.sheetMode = .half
    }
    func toQuarterSheet() {
        self.sheetMode = .quarter
    }
}

enum SheetMode {
    case quarter
    case full
    case half
}
