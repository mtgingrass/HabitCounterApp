//
//  ContentView.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 4/21/25.
//  Git Repo HabitCounterApp.git

import SwiftUI

struct ContentView: View {
    @StateObject private var mainVM = MainCounterViewModel()
    @StateObject private var subHabitVM = SubHabitListViewModel()
    @State private var showMainResetConfirmation = false

    var body: some View {
        VStack(spacing: 24) {
            // Top-right menu
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

            // Main counter section
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

            // Start date & reset button
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

            // Sub-Habit Section
            VStack(alignment: .leading, spacing: 8) {
                Divider().padding(.vertical, 12)

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
