//
//  MainCounterViewModel.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 5/8/25.
//

import SwiftUI

class MainCounterViewModel: ObservableObject {
    @Published var startDate: Date

    init() {
        self.startDate = UserDefaults.standard.object(forKey: "startDate") as? Date ?? Date()
    }

    var record: Int {
        get {
            UserDefaults.standard.integer(forKey: "mainRecord")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "mainRecord")
        }
    }

    var dayCount: Int {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())
        let diff = calendar.dateComponents([.day], from: startOfStartDate, to: startOfToday).day ?? 0
        return diff + 1
    }

    var recordText: String {
        return "Record: \(record) days"
    }

    func resetRecord() {
        record = dayCount
    }

    func updateRecordIfNeeded() {
        if dayCount > record {
            record = dayCount
        }
    }
}
