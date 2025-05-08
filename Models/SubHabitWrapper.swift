//
//  SubHabitWrapper.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 5/8/25.
//

import SwiftUI

struct SubHabitWrapper: Identifiable {
    let id = UUID()
    @ObservedObject var counter: SubHabit
}
