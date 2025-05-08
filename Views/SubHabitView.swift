//
//  SubHabitView.swift
//  HabitCounterApp
//
//  Created by Mark Gingrass on 5/8/25.
//

import SwiftUI

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
