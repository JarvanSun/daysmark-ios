//
//  LiveActivityService.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/09/04.
//

@preconcurrency import ActivityKit
import Foundation
import SwiftData

@MainActor
public final class LiveActivityService {
    private let container: ModelContainer
    private let records: LiveActivityRecords
    private let timeZone: () -> TimeZone
    private let resolver = EventOccurrenceResolver()
    private let planner = LiveActivityPlanner()

    private var observedActivityIDs: Set<String> = []

    public init(
        container: ModelContainer,
        defaults: UserDefaults,
        timeZone: @escaping () -> TimeZone
    ) {
        self.container = container
        self.timeZone = timeZone
        records = LiveActivityRecords(defaults: defaults)
    }

    func reconcile(at now: Date) async {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            await endAll()
            return
        }

        let candidates = candidates(at: now)

        await updateRunningActivities(toMatch: candidates)
        startMissingActivities(for: candidates, now: now)
    }
}

// MARK: - Private

private extension LiveActivityService {
    struct Candidate {
        let event: CountdownEvent
        let plan: LiveActivityPlan
    }

    func endAll() async {
        for activity in Activity<ImportantDateActivityAttributes>.activities {
            await end(activity)
        }
    }

    func candidates(at now: Date) -> [Candidate] {
        let visible = FetchDescriptor<CountdownEvent>(
            predicate: #Predicate { $0.deletedAt == nil && $0.permanentDeletionRequestedAt == nil }
        )
        let events = (try? container.mainContext.fetch(visible)) ?? []

        return events.compactMap { candidate(for: $0, now: now) }
    }

    func candidate(for event: CountdownEvent, now: Date) -> Candidate? {
        guard
            let occurrence = resolver.nextOccurrence(
                for: event,
                now: now,
                userTimeZone: timeZone()
            ),
            let plan = planner.plan(
                occurrence: occurrence,
                semantics: event.timeSemantics,
                now: now
            )
        else { return nil }

        return Candidate(event: event, plan: plan)
    }

    func updateRunningActivities(toMatch candidates: [Candidate]) async {
        let plans = Dictionary(
            candidates.map { ($0.event.id, $0.plan) },
            uniquingKeysWith: { first, _ in first }
        )

        for activity in Activity<ImportantDateActivityAttributes>.activities {
            switch plans[activity.attributes.eventID] {
            case let plan?:
                await activity.update(content(for: plan))
                follow(activity, until: plan.terminalDate)
            case nil:
                await end(activity)
            }
        }
    }

    func startMissingActivities(for candidates: [Candidate], now: Date) {
        let running = Set(
            Activity<ImportantDateActivityAttributes>.activities.map(\.attributes.eventID)
        )

        for candidate in candidates where !running.contains(candidate.event.id) {
            guard !records.wasDismissed(candidate.event.id, now: now),
                let attributes = attributes(for: candidate.event)
            else { continue }

            let activity = try? Activity.request(
                attributes: attributes,
                content: content(for: candidate.plan),
                pushType: nil,
                style: .standard
            )

            if let activity {
                follow(activity, until: candidate.plan.terminalDate)
            }
        }
    }

    func attributes(for event: CountdownEvent) -> ImportantDateActivityAttributes? {
        AppRequest.event(event.id).url.map {
            ImportantDateActivityAttributes(
                eventID: event.id,
                presentedTitle: event.title,
                symbolName: event.icon.isEmpty ? "calendar" : event.icon,
                deepLink: $0
            )
        }
    }

    func end(_ activity: Activity<ImportantDateActivityAttributes>) async {
        await activity.end(nil, dismissalPolicy: .immediate)
        records.clear(activity.attributes.eventID)
    }

    func content(
        for plan: LiveActivityPlan
    ) -> ActivityContent<ImportantDateActivityAttributes.ContentState> {
        ActivityContent(
            state: ImportantDateActivityAttributes.ContentState(
                targetDate: plan.targetDate,
                target: plan.target,
                isTerminal: plan.isTerminal
            ),
            staleDate: plan.terminalDate,
            relevanceScore: plan.isTerminal ? 100 : 90
        )
    }

    func follow(_ activity: Activity<ImportantDateActivityAttributes>, until terminalDate: Date) {
        let eventID = activity.attributes.eventID

        guard observedActivityIDs.insert(activity.id).inserted else { return }

        Task { [weak self] in
            for await state in activity.activityStateUpdates {
                if state == .dismissed {
                    self?.records.noteDismissal(of: eventID, until: terminalDate)
                }

                if state == .dismissed || state == .ended {
                    break
                }
            }

            self?.observedActivityIDs.remove(activity.id)
        }
    }
}
