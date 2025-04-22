//
//  ContentView.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 4/21/25.
//  Git Repo HabitCounterApp.git

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
                
                VStack(alignment: .trailing) {
                    Text("Day \(counter.dayCount)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Record: \(counter.recordValue) days")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
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
            HStack {
                Spacer()
                Menu {
                    Button("Reset Main Record") {
                        mainVM.resetRecord()
                    }

                    ForEach(subHabitVM.subHabits) { wrapper in
                        Button("Reset \(wrapper.counter.title) Record") {
                            wrapper.counter.resetRecord()
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .imageScale(.large)
                        .padding(.trailing)
                }
            }

            Spacer()

            VStack(spacing: 4) {
                Text("Days Free")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Day \(mainVM.dayCount)")
                    .font(.system(size: 52, weight: .bold))
                    .onAppear {
                        mainVM.updateRecordIfNeeded()
                    }
                Text(mainVM.recordText)
                    .font(.caption)
                    .foregroundColor(.secondary)
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
                HStack {
                    Text("Start Date:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Spacer()

                    DatePicker("", selection: $mainVM.startDate, in: ...Date(), displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .onChange(of: mainVM.startDate) { newDate in
                            UserDefaults.standard.set(newDate, forKey: "startDate")
                            mainVM.updateRecordIfNeeded()
                        }
                }

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
            }

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
