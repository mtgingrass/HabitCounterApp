//
//  SubHabitListViewModel.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 5/8/25.
//

import SwiftUI

class SubHabitListViewModel: ObservableObject {
    @Published var subHabits: [SubHabitWrapper] = [
        SubHabitWrapper(counter: SubHabit(title: "Workout", startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)),
        SubHabitWrapper(counter: SubHabit(title: "Reading", startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!))
    ]

    @Published var expandedCounterID: UUID?
    @Published var subCounterToReset: SubHabit?
}
