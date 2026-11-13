//
//  RelativeTimePhrase.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/03.
//

import Foundation

public struct RelativeTimePhrase: Equatable, Hashable, Sendable {
    public let text: String
    public let number: String?
    public let targetDate: Date?
    let phase: Phase

    init(text: String, number: String?, targetDate: Date?, phase: Phase) {
        self.text = text
        self.number = number
        self.targetDate = targetDate
        self.phase = phase
    }

    public init(_ count: DayCount) {
        let text =
            switch (count.direction, count.days) {
            case (.today, _): String(localized: "phrase.today", bundle: .module)
            case (.upcoming, 1): String(localized: "phrase.tomorrow", bundle: .module)
            case (.past, 1): String(localized: "phrase.yesterday", bundle: .module)
            case (.upcoming, _):
                String(localized: "phrase.future.days \(count.days)", bundle: .module)
            case (.past, _): String(localized: "phrase.past.days \(count.days)", bundle: .module)
            }
        let number = count.days.formatted()

        self.init(
            text: text,
            number: text.contains(number) ? number : nil,
            targetDate: nil,
            phase: .point
        )
    }

    init(target: Date, now: Date, locale: Locale) {
        let seconds = target.timeIntervalSince(now)

        guard abs(seconds) >= 1 else {
            self.init(
                text: String(localized: "phrase.now", bundle: .module),
                number: nil,
                targetDate: target,
                phase: .point
            )
            return
        }

        let isWithinTheHour = abs(seconds) < 3_600
        let secondsPerUnit: TimeInterval = isWithinTheHour ? 60 : 3_600
        let magnitude = max(1, Int((abs(seconds) / secondsPerUnit).rounded(.up)))
        let signedMagnitude = seconds > 0 ? magnitude : -magnitude
        let components =
            switch isWithinTheHour {
            case true: DateComponents(minute: signedMagnitude)
            case false: DateComponents(hour: signedMagnitude)
            }
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = locale
        formatter.unitsStyle = .full

        self.init(
            text: formatter.localizedString(from: components),
            number: magnitude.formatted(.number.locale(locale)),
            targetDate: target,
            phase: .point
        )
    }

    var parts: Parts? {
        guard let number, let range = text.range(of: number) else { return nil }

        return Parts(
            leading: String(text[..<range.lowerBound])
                .trimmingCharacters(in: .whitespacesAndNewlines),
            number: number,
            trailing: String(text[range.upperBound...])
                .trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    public func updated(at now: Date, locale: Locale) -> RelativeTimePhrase {
        guard let targetDate else { return self }

        return RelativeTimePhrase(target: targetDate, now: now, locale: locale).placed(in: phase)
    }

    func placed(in phase: Phase) -> RelativeTimePhrase {
        let text =
            switch phase {
            case .point: text
            case .beforeStart: String(localized: "phrase.range.starts \(text)", bundle: .module)
            case .ongoing: String(localized: "phrase.range.ends \(text)", bundle: .module)
            case .ended: String(localized: "phrase.range.ended \(text)", bundle: .module)
            }

        return RelativeTimePhrase(text: text, number: number, targetDate: targetDate, phase: phase)
    }
}

extension RelativeTimePhrase {
    enum Phase: Equatable, Hashable, Sendable {
        case point
        case beforeStart
        case ongoing
        case ended
    }

    struct Parts: Equatable, Hashable, Sendable {
        let leading: String
        let number: String
        let trailing: String
    }
}
