//
//  EventDraftRecords.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

extension EventDraft {
    public init(_ event: CountdownEvent, at now: Date, in userTimeZone: TimeZone) {
        let eventTimeZone = TimeZone(identifier: event.timeZoneIdentifier)
        let calendar = Calendar(identifier: .gregorian)
        let resolvedTarget = event.startDateSpecification.resolvedDate(
            semantics: event.timeSemantics,
            eventTimeZone: eventTimeZone,
            userTimeZone: userTimeZone
        )
        let resolvedEnd =
            event.endDateSpecification?.resolvedDate(
                semantics: event.timeSemantics,
                eventTimeZone: eventTimeZone,
                userTimeZone: userTimeZone
            ) ?? event.rangeDurationSeconds.flatMap {
                resolvedTarget?.addingTimeInterval($0)
            }
            ?? event.rangeCalendarDaySpan.flatMap { span in
                resolvedTarget.flatMap { start in
                    var selected = Calendar(identifier: event.calendarSystem.identifier)
                    selected.timeZone = userTimeZone
                    return selected.date(byAdding: .day, value: span, to: start)
                }
            }

        self.init(
            startingOn: resolvedTarget ?? calendar.date(from: event.targetComponents) ?? now,
            categoryID: event.categoryID,
            timeZone: event.timeSemantics == .fixedInstant
                ? eventTimeZone ?? userTimeZone
                : userTimeZone
        )

        title = event.title
        endDate = resolvedEnd ?? event.endComponents.flatMap(calendar.date(from:))
        calendarSystem = event.calendarSystem
        timeSemantics = event.timeSemantics
        islamicObservationConfirmed = event.calendarSystem == .islamicUmmAlQura
        countsFromDayOne = event.countsFromDayOne
        repeatRule = event.repeatRule
        repeatInterval = event.repeatInterval
        repeatUnit = event.repeatUnit
        icon = event.icon.isEmpty ? "star" : event.icon
        isSpotlightHidden = event.isSpotlightHidden
        reminders = (event.reminders ?? [])
            .map {
                ReminderDraft(
                    id: $0.id,
                    kind: $0.kind,
                    minutesBefore: $0.minutesBefore,
                    daysBefore: $0.daysBefore,
                    hour: $0.hour,
                    minute: $0.minute
                )
            }
            .sorted { $0.daysBefore < $1.daysBefore }
        specialReminderNodes = (event.specialReminderNodes ?? [])
            .map { SpecialReminderNodeDraft(id: $0.id, kind: $0.kind, value: $0.value) }
            .sorted { $0.id.uuidString < $1.id.uuidString }
        specialNodeNotificationMinuteOfDay = event.specialNodeNotificationHour.flatMap { hour in
            event.specialNodeNotificationMinute.map { hour * 60 + $0 }
        }
        baseRevisionID = event.currentRevisionID
    }

    init(_ revision: EventRevision, at now: Date, in userTimeZone: TimeZone) {
        self.init(revision.snapshotEvent(in: userTimeZone, at: now), at: now, in: userTimeZone)

        let decoder = JSONDecoder()
        reminders =
            (revision.ordinaryReminderSnapshotData
            .flatMap { try? decoder.decode([OrdinaryReminderSnapshot].self, from: $0) } ?? [])
            .map {
                ReminderDraft(
                    id: $0.id,
                    kind: $0.kindRaw.flatMap(ReminderRuleKind.init(rawValue:))
                        ?? .allDayOffsetAtTime,
                    minutesBefore: $0.minutesBefore,
                    daysBefore: $0.daysBefore,
                    hour: $0.hour,
                    minute: $0.minute
                )
            }
        specialReminderNodes =
            (revision.specialNodeSnapshotData
            .flatMap { try? decoder.decode([SpecialReminderNodeSnapshot].self, from: $0) } ?? [])
            .compactMap { node in
                SpecialReminderNodeKind(rawValue: node.kindRaw).map {
                    SpecialReminderNodeDraft(id: node.id, kind: $0, value: node.value)
                }
            }
    }
}
