//
//  ReminderTimePicker.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public struct ReminderTimePicker<Label: View>: View {
    @Environment(\.calendar) private var calendar

    private let minuteOfDay: Int
    private let onChange: (Int) -> Void
    private let label: () -> Label

    public init(
        minuteOfDay: Int,
        onChange: @escaping (Int) -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.minuteOfDay = minuteOfDay
        self.onChange = onChange
        self.label = label
    }

    public var body: some View {
        DatePicker(selection: selection, displayedComponents: .hourAndMinute, label: label)
    }

    private var selection: Binding<Date> {
        let date = calendar.date(
            from: DateComponents(hour: minuteOfDay / 60, minute: minuteOfDay % 60)
        )

        return Binding(date ?? .now) { date in
            let components = calendar.dateComponents([.hour, .minute], from: date)

            onChange((components.hour ?? 0) * 60 + (components.minute ?? 0))
        }
    }
}

#if DEBUG
#Preview {
    @Previewable @State var minuteOfDay = PreviewObjectPool().reminderMinuteOfDay

    ReminderTimePicker(minuteOfDay: minuteOfDay, onChange: { minuteOfDay = $0 }) {
        SettingsLabel(title: Text(verbatim: PreviewObjectPool().rowTitle), symbol: .clock)
    }
    .padding()
    .background(DaysMarkColor.canvas.color.ignoresSafeArea())
}
#endif
