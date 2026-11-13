//
//  EventEditorDateSection.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorDateSection: View {
    let viewModel: EventEditorViewModel

    var body: some View {
        Section {
            DatePicker(selection: targetDate, displayedComponents: .date) {
                SettingsLabel(title: Text("editor.date.start", bundle: .module), symbol: .calendar)
            }

            Toggle(isOn: Binding(viewModel.hasTime) { viewModel.toggleTime($0) }) {
                SettingsLabel(title: Text("editor.date.addTime", bundle: .module), symbol: .clock)
            }

            if viewModel.hasTime {
                DatePicker(selection: targetDate, displayedComponents: .hourAndMinute) {
                    SettingsLabel(title: Text("editor.date.time", bundle: .module))
                }
            }

            Toggle(isOn: Binding(viewModel.hasEndDate) { viewModel.toggleEndDate($0) }) {
                SettingsLabel(title: Text("editor.date.addEnd", bundle: .module), symbol: .flag)
            }

            if viewModel.hasEndDate {
                DatePicker(
                    selection: endDate,
                    in: viewModel.draft.targetDate...,
                    displayedComponents: .date
                ) {
                    SettingsLabel(title: Text("editor.date.end", bundle: .module))
                }

                if viewModel.hasTime {
                    DatePicker(
                        selection: endDate,
                        in: viewModel.draft.targetDate...,
                        displayedComponents: .hourAndMinute
                    ) {
                        SettingsLabel(title: Text("editor.date.time", bundle: .module))
                    }
                }
            }
        }
        .environment(\.calendar, viewModel.datePickerCalendar)
        .environment(\.timeZone, viewModel.datePickerCalendar.timeZone)
    }

    private var targetDate: Binding<Date> {
        Binding(viewModel.draft.targetDate) { viewModel.moveTargetDate(to: $0) }
    }

    private var endDate: Binding<Date> {
        Binding(viewModel.endDate) { viewModel.moveEndDate(to: $0) }
    }
}
