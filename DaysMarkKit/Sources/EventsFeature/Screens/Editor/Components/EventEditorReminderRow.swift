//
//  EventEditorReminderRow.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorReminderRow: View {
    @Binding var reminder: ReminderDraft
    let isAllDay: Bool

    var body: some View {
        switch isAllDay {
        case true: allDayReminder
        case false: timedReminder
        }
    }

    private var allDayReminder: some View {
        HStack {
            Picker(selection: $reminder.daysBefore) {
                ForEach(reminder.dayOffsetChoices, id: \.self) {
                    Text(verbatim: reminder.dayOffsetDescription($0))
                        .tag($0)
                }
            } label: {
                Text(verbatim: reminder.dayOffsetTitle)
            }
            .labelsHidden()

            Spacer()

            ReminderTimePicker(
                minuteOfDay: reminder.time.minuteOfDay,
                onChange: { moveReminder(to: TimeOfDay(minuteOfDay: $0)) }
            ) {
                Text("editor.reminder.time", bundle: .module)
            }
            .labelsHidden()
        }
    }

    private func moveReminder(to time: TimeOfDay) {
        reminder.hour = time.hour
        reminder.minute = time.minute
    }

    private var timedReminder: some View {
        Picker(selection: Binding(reminder.minutesBefore ?? 0) { reminder.minutesBefore = $0 }) {
            ForEach(reminder.exactOffsetChoices, id: \.self) {
                Text(verbatim: reminder.exactOffsetDescription($0))
                    .tag($0)
            }
        } label: {
            Text("editor.reminder.offset", bundle: .module)
        }
    }
}
