//
//  ImportReminderOptions.swift
//  SettingsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct ImportReminderOptions: View {
    @Binding var reminder: ImportReminderSuggestion

    var body: some View {
        Toggle(isOn: $reminder.isEnabled) {
            Label(Text("settings.import.reminder.toggle", bundle: .module), symbol: .bell)
                .textStyle(DaysMarkColor.textPrimary, DaysMarkFont.rowTitle)
        }

        if reminder.isEnabled {
            Picker(selection: $reminder.daysBefore) {
                ForEach(ReminderDraft().dayOffsetChoices, id: \.self) { days in
                    Text(verbatim: ReminderDraft().dayOffsetDescription(days))
                        .tag(days)
                }
            } label: {
                Text("settings.import.reminder.offset", bundle: .module)
            }

            ReminderTimePicker(
                minuteOfDay: reminder.time.minuteOfDay,
                onChange: { reminder.time = TimeOfDay(minuteOfDay: $0) },
                label: { Text("settings.import.reminder.time", bundle: .module) }
            )
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var reminder = PreviewObjectPool().reminderSuggestion

    Form {
        ImportReminderOptions(reminder: $reminder)
    }
}
#endif
