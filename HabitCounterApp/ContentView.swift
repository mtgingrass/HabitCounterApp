//
//  ContentView.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 4/21/25.
//

import SwiftUI

class MainCounterViewModel: ObservableObject {
    @AppStorage("startDate") var startDate = Date()

    var dayCount: Int {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())
        return (calendar.dateComponents([.day], from: startOfStartDate, to: startOfToday).day ?? 0) + 1
    }
}

class SubHabitListViewModel: ObservableObject {
    @Published var subHabits: [SubHabitWrapper] = [
        SubHabitWrapper(counter: SubHabit(title: "Workout", startDate: Calendar.current.date(byAdding: .day, value: -3, to: Date())!)),
        SubHabitWrapper(counter: SubHabit(title: "Reading", startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date())!))
    ]

    @Published var expandedCounterID: UUID?
    @Published var subCounterToReset: SubHabit?
}

class SubHabit: Identifiable, ObservableObject {
    let id = UUID()
    let title: String
    @Published var startDate: Date
    
    init(title: String, startDate: Date) {
        self.title = title
        self.startDate = startDate
    }

    var dayCount: Int {
        let calendar = Calendar.current
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfToday = calendar.startOfDay(for: Date())
        return calendar.dateComponents([.day], from: startOfStartDate, to: startOfToday).day ?? 0 + 1
    }
}

struct SubHabitWrapper: Identifiable {
    let id = UUID()
    @ObservedObject var counter: SubHabit
}

struct SubHabitView: View {
    @ObservedObject var counter: SubHabit
    let isExpanded: Bool
    let onTap: () -> Void
    let onResetRequest: (SubHabit) -> Void
    let onDateChanged: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(counter.title)
                    .font(.headline)
                
                Spacer()
                
                Text("Day \(counter.dayCount)")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation {
                    onTap()
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Button(action: {
                        onResetRequest(counter)
                    }) {
                        Text("Reset to Today")
                            .font(.caption)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(6)
                    }

                    HStack {
                        Text("Start Date:")
                            .font(.footnote)
                            .foregroundColor(.secondary)

                        Spacer()

                        DatePicker("", selection: $counter.startDate, in: ...Date(), displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .onChange(of: counter.startDate) {
                                onDateChanged()
                            }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.15))
        .cornerRadius(12)
    }
}

struct ContentView: View {
    @StateObject private var mainVM = MainCounterViewModel()
    @StateObject private var subHabitVM = SubHabitListViewModel()
    @State private var showMainResetConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 4) {
                Text("Days Free")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Day \(mainVM.dayCount)")
                    .font(.system(size: 52, weight: .bold))
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.1))
                    .shadow(radius: 4)
            )
            .padding(.horizontal)

            Spacer()

            VStack(spacing: 16) {
                Button(action: {
                    showMainResetConfirmation = true
                }) {
                    Text("Reset to Today")
                        .font(.caption)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.8))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .alert("Reset main counter?", isPresented: $showMainResetConfirmation) {
                    Button("Reset", role: .destructive) {
                        mainVM.startDate = Date()
                    }
                    Button("Cancel", role: .cancel) { }
                }

                HStack {
                    Text("Start Date:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    DatePicker("", selection: $mainVM.startDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
            }
            .padding(.horizontal)

            VStack(alignment: .leading, spacing: 8) {
                Divider()
                    .padding(.vertical, 12)

                Text("Sub-Habits")
                    .font(.headline)
                    .padding(.horizontal)

                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(subHabitVM.subHabits) { wrapper in
                            SubHabitView(
                                counter: wrapper.counter,
                                isExpanded: subHabitVM.expandedCounterID == wrapper.counter.id,
                                onTap: {
                                    subHabitVM.expandedCounterID = subHabitVM.expandedCounterID == wrapper.counter.id ? nil : wrapper.counter.id
                                },
                                onResetRequest: { subHabit in
                                    subHabitVM.subCounterToReset = subHabit
                                },
                                onDateChanged: {
                                    subHabitVM.expandedCounterID = nil
                                }
                            )
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }

            Spacer()
        }
        .padding()
        .alert("Reset sub-habit?", isPresented: Binding(get: {
            subHabitVM.subCounterToReset != nil
        }, set: { newValue in
            if !newValue {
                subHabitVM.subCounterToReset = nil
            }
        })) {
            Button("Reset", role: .destructive) {
                subHabitVM.subCounterToReset?.startDate = Date()
                subHabitVM.subCounterToReset = nil
            }
            Button("Cancel", role: .cancel) {
                subHabitVM.subCounterToReset = nil
            }
        }
    }
}

#Preview {
    ContentView()
}
