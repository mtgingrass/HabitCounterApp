//
//  SubHabit.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 5/8/25.
//

import Foundation
import SwiftUI

class SubHabit: Identifiable, ObservableObject {
    let id = UUID()
    let title: String
    @Published var startDate: Date
    @Published var recordVersion = 0
    @Published var recordValue: Int

    init(title: String, startDate: Date) {
        self.title = title
        self.startDate = startDate
        let key = "record_\(title)"
        self.recordValue = UserDefaults.standard.integer(forKey: key)
    }

    var dayCount: Int {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())

        if let days = calendar.dateComponents([.day], from: startOfStartDate, to: startOfToday).day {
            return max(1, days + 1)
        } else {
            return 1
        }
    }

    var record: Int {
        recordValue
    }

    func resetRecord() {
        let key = "record_\(title)"
        recordValue = dayCount
        UserDefaults.standard.set(recordValue, forKey: key)
    }

    func updateRecordIfNeeded() {
        let key = "record_\(title)"
        if dayCount > recordValue {
            recordValue = dayCount
            UserDefaults.standard.set(recordValue, forKey: key)
        }
    }
}
