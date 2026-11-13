//
//  EventEditorRulesSection.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import DesignSystem
import SunUserInterface
import SwiftUI

struct EventEditorRulesSection: View {
    @AppStorage(NotificationPreferences.Key.newReminderMinuteOfDay.rawValue)
    private var newReminderMinuteOfDay = NotificationPreferences()
        .defaultNewReminderTime.minuteOfDay

    @Bindable var viewModel: EventEditorViewModel

    var body: some View {
        Section {
            ForEach($viewModel.draft.reminders) { $reminder in
                EventEditorReminderRow(reminder: $reminder, isAllDay: !viewModel.hasTime)
            }
            .onDelete { viewModel.removeReminders(at: $0) }

            Button {
                viewModel.addReminder(at: TimeOfDay(minuteOfDay: newReminderMinuteOfDay))
            } label: {
                SettingsLabel(title: Text("editor.reminder.add", bundle: .module), symbol: .bell)
            }

            Picker(
                selection: Binding(viewModel.draft.repeatRule) { viewModel.selectRepeatRule($0) }
            ) {
                ForEach(viewModel.draft.repeatRule.editorCases, id: \.self) {
                    Text(verbatim: $0.displayName)
                        .tag($0)
                }
            } label: {
                SettingsLabel(title: Text("editor.repeat.title", bundle: .module), symbol: .repeat)
            }

            Picker(
                selection: Binding(viewModel.draft.calendarSystem) {
                    viewModel.selectCalendarSystem($0)
                }
            ) {
                ForEach(EventCalendarSystem.allCases, id: \.self) {
                    Text($0.title)
                        .tag($0)
                }
            } label: {
                SettingsLabel(title: Text("editor.calendar.title", bundle: .module), symbol: .globe)
            }

            Button {
                viewModel.editSpecialNodes()
            } label: {
                LabeledContent {
                    HStack {
                        viewModel.draft.specialNodesSummary

                        Image(style: DaysMarkImage.chevronForward)
                            .textStyle(DaysMarkColor.textTertiary, DaysMarkFont.disclosure)
                    }
                } label: {
                    SettingsLabel(
                        title: Text("editor.specialNodes.row", bundle: .module),
                        symbol: .target
                    )
                }
            }
        } header: {
            Text("editor.rules.title", bundle: .module)
        }
    }
}
