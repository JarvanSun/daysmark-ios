//
//  HomeViewModelTests.swift
//  EventsFeatureTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation
import TestSupport
import Testing

@testable import DaysMarkCore
@testable import EventsFeature

struct HomeViewModelTests {
    @Test(arguments: [false, true])
    func togglePinThenPinsOrUnpinsTheEvent(wasPinned: Bool) {
        // Given
        let event = CountdownEvent.mock()
        let events = EventRepositorySpy(
            storedEvents: [event],
            storedFocusSelections: wasPinned ? [.mock(selecting: event.id)] : []
        )
        let viewModel = makeViewModel(events: events)
        viewModel.reload()

        // When
        viewModel.togglePin(event.id)

        // Then
        #expect(events.selections == [wasPinned ? nil : event.id])
        #expect(viewModel.issue == nil)
    }

    @Test func togglePinWhenItFailsThenReportsTheIssueUntilARetrySucceeds() {
        // Given
        let events = EventRepositorySpy()
        let viewModel = makeViewModel(events: events)
        events.error = .storeFailure

        // When
        viewModel.togglePin(.mockActive)
        let failed = viewModel.issue
        events.error = nil
        viewModel.togglePin(.mockActive)

        // Then
        #expect(failed == .actionFailed)
        #expect(viewModel.issue == nil)
    }

    @Test func deleteWhenItFailsThenReportsTheIssue() {
        // Given
        let events = EventRepositorySpy(failingIDs: [.mockActive], error: .inRecentlyDeleted)
        let viewModel = makeViewModel(events: events)

        // When
        viewModel.delete(.mockActive)

        // Then
        #expect(viewModel.issue == .inRecentlyDeleted)
        #expect(events.deletedIDs == [.mockActive])
    }

    @Test func deleteWhenItSucceedsThenClearsAnEarlierIssue() {
        // Given
        let events = EventRepositorySpy(failingIDs: [.mockActive], error: .storeFailure)
        let viewModel = makeViewModel(events: events)
        viewModel.delete(.mockActive)

        // When
        viewModel.delete(.mockOther)

        // Then
        #expect(viewModel.issue == nil)
        #expect(events.deletedIDs == [.mockActive, .mockOther])
    }

    @Test func acknowledgeIssueThenClearsIt() {
        // Given
        let viewModel = makeViewModel(
            events: .init(failingIDs: [.mockActive], error: .storeFailure)
        )
        viewModel.delete(.mockActive)

        // When
        viewModel.acknowledgeIssue()

        // Then
        #expect(viewModel.issue == nil)
    }

    @Test func deleteSelectionThenDeletesOnlySelectedEventsThatAreShown() {
        // Given
        let shown = CountdownEvent.mock("Shown")
        let alsoShown = CountdownEvent.mock("Also shown")
        let events = EventRepositorySpy(storedEvents: [shown, alsoShown])
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        viewModel.startSelecting()
        viewModel.selection = [shown.id, alsoShown.id, .mockMissing]

        // When
        viewModel.deleteSelection()

        // Then
        #expect(Set(events.deletedIDs) == [shown.id, alsoShown.id])
        #expect(viewModel.selection.isEmpty)
        #expect(!viewModel.isSelecting)
    }

    @Test func deleteSelectionWhenSomeFailThenKeepsThemSelectedAndCountsThem() {
        // Given
        let succeeds = CountdownEvent.mock("Succeeds")
        let fails = CountdownEvent.mock("Fails")
        let events = EventRepositorySpy(
            storedEvents: [succeeds, fails],
            failingIDs: [fails.id],
            error: .storeFailure
        )
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        viewModel.startSelecting()
        viewModel.selection = [succeeds.id, fails.id]

        // When
        viewModel.deleteSelection()

        // Then
        #expect(Set(events.deletedIDs) == [succeeds.id, fails.id])
        #expect(viewModel.selection == [fails.id])
        #expect(viewModel.isSelecting)
        #expect(viewModel.issue == .batchDeleteFailed(count: 1))
    }

    @Test func deleteSelectionWithoutASelectionThenDeletesNothing() {
        // Given
        let events = EventRepositorySpy(storedEvents: [.mock()])
        let viewModel = makeViewModel(events: events)
        viewModel.reload()
        viewModel.startSelecting()

        // When
        viewModel.deleteSelection()

        // Then
        #expect(events.deletedIDs.isEmpty)
        #expect(!viewModel.isSelecting)
    }

    @Test func selectAllThenSelectsEveryShownEvent() {
        // Given
        let events = [CountdownEvent.mock("First"), .mock("Second")]
        let viewModel = makeViewModel(events: .init(storedEvents: events))
        viewModel.reload()

        // When
        viewModel.selectAll()

        // Then
        #expect(viewModel.selection == Set(events.map(\.id)))
    }

    @Test func finishSelectingThenClearsTheSelection() {
        // Given
        let viewModel = makeViewModel()
        viewModel.startSelecting()
        viewModel.selection = [.mockActive]

        // When
        viewModel.finishSelecting()

        // Then
        #expect(viewModel.selection.isEmpty)
        #expect(!viewModel.isSelecting)
    }

    @Test func selectCategoryThenFiltersAndClearsTheSelection() {
        // Given
        let viewModel = makeViewModel()
        viewModel.selection = [.mockActive]

        // When
        viewModel.selectCategory(BuiltInCategory.birthday.id)

        // Then
        #expect(viewModel.filter.categoryID == BuiltInCategory.birthday.id)
        #expect(viewModel.selection.isEmpty)
    }

    @Test func resetFiltersThenShowsEverything() {
        // Given
        let viewModel = makeViewModel()
        viewModel.selectCategory(BuiltInCategory.birthday.id)

        // When
        viewModel.resetFilters()

        // Then
        #expect(viewModel.filter.categoryID == nil)
    }

    @Test func contentThenAppliesTheSessionFiltersAndSearch() {
        // Given
        let birthday = EventCategory(builtIn: .birthday)
        let party = CountdownEvent.mock("Party", category: birthday)
        let trip = CountdownEvent.mock("Trip")
        let viewModel = makeViewModel(events: .init(storedEvents: [party, trip]))
        viewModel.reload()
        viewModel.selectCategory(birthday.id)

        // When
        let filtered = viewModel.content
        viewModel.filter.searchText = "trip"
        let searched = viewModel.content

        // Then
        #expect(filtered.rows.map(\.id) == [party.id])
        #expect(searched.rows.map(\.id) == [trip.id])
    }

    @Test func reloadThenOffersOnlyCategoriesThatAreNotDeleted() {
        // Given
        let travel = EventCategory(name: "Travel")
        let deleted = EventCategory(name: "Deleted")
        deleted.deletedAt = .mockNow
        let viewModel = makeViewModel(categories: .init(storedCategories: [travel, deleted]))

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.data.categories.map(\.id) == [travel.id])
        #expect(viewModel.issue == nil)
    }

    @Test func reloadThenResolvesThePinnedEventFromTheFocusSelections() {
        // Given
        let event = CountdownEvent.mock()
        let viewModel = makeViewModel(
            events: .init(
                storedEvents: [event],
                storedFocusSelections: [.mock(selecting: event.id)]
            )
        )

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.data.pinnedEventID == event.id)
        #expect(viewModel.content.pinAction(for: event.id) == .unpin)
    }

    @Test func reloadWhenTheStoreFailsThenReportsTheIssue() {
        // Given
        let viewModel = makeViewModel(categories: .init(readError: .storeFailure))

        // When
        viewModel.reload()

        // Then
        #expect(viewModel.issue == .actionFailed)
    }

    @Test func addEventThenUsesTheSelectedCategoryOrImportantDate() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(events: .init(storedEvents: [.mock()]), router: router)
        viewModel.reload()

        // When
        viewModel.addEvent()
        viewModel.selectCategory(BuiltInCategory.birthday.id)
        viewModel.addEvent()

        // Then
        #expect(
            router.calls == [
                .editor(.new(categoryID: BuiltInCategory.important.id)),
                .editor(.new(categoryID: BuiltInCategory.birthday.id)),
            ]
        )
    }

    @Test func addEventWithoutEventsThenUsesImportantDate() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.selectCategory(BuiltInCategory.birthday.id)

        // When
        viewModel.addEvent()

        // Then
        #expect(router.calls == [.editor(.new(categoryID: BuiltInCategory.important.id))])
    }

    @Test func eventIntentsThenRouteToTheirScreens() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)

        // When
        viewModel.open(CountdownEvent.ID.mockActive)
        viewModel.openPinned(.mockActive)
        viewModel.share(.mockActive)
        viewModel.openSettings()

        // Then
        #expect(
            router.calls == [
                .detail(.mockActive),
                .detailFromFocus(.mockActive),
                .sharing(.mockActive),
                .settings(.root),
            ]
        )
    }

    @Test func openACollectionThenShowsHomeWithThatCategory() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.selectCategory(BuiltInCategory.important.id)

        // When
        viewModel.open(.collection(.birthdays))

        // Then
        #expect(viewModel.filter.categoryID == BuiltInCategory.birthday.id)
        #expect(router.calls == [.home])
    }

    @Test func openTheAllCollectionThenClearsTheCategory() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.selectCategory(BuiltInCategory.birthday.id)

        // When
        viewModel.open(.collection(.all))

        // Then
        #expect(viewModel.filter.categoryID == nil)
        #expect(router.calls == [.home])
    }

    @Test func openAnExistingCategoryThenSelectsIt() {
        // Given
        let router = EventsRouterSpy()
        let category = EventCategory(name: "Travel")
        let viewModel = makeViewModel(
            categories: .init(storedCategories: [category]),
            router: router
        )
        viewModel.reload()

        // When
        viewModel.open(.category(category.id))

        // Then
        #expect(viewModel.filter.categoryID == category.id)
        #expect(router.calls == [.home])
    }

    @Test func openACategoryThatNoLongerExistsThenShowsTheWidgetInstructions() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)

        // When
        viewModel.open(.category(.mockMissing))
        viewModel.open(.widgets)

        // Then
        #expect(viewModel.filter.categoryID == nil)
        #expect(router.calls == [.requestedSettings(.widgets), .requestedSettings(.widgets)])
    }

    @Test func openACollectionWhileASheetIsUpThenKeepsTheFiltersAndTheSheet() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.selectCategory(BuiltInCategory.important.id)
        router.isPresentingSheet = true

        // When
        viewModel.open(.collection(.birthdays))
        let whileEditing = (viewModel.filter, router.calls)
        router.isPresentingSheet = false
        viewModel.open(.collection(.birthdays))

        // Then
        #expect(whileEditing.0 == .init(categoryID: BuiltInCategory.important.id))
        #expect(whileEditing.1.isEmpty)
        #expect(viewModel.filter.categoryID == BuiltInCategory.birthday.id)
        #expect(router.calls == [.home])
    }

    @Test func openAVisibleEventThenRequestsDetail() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(
            events: .init(storedEvents: [.mock(id: .mockActive)]),
            router: router
        )
        viewModel.reload()

        // When
        viewModel.open(.event(.mockActive))

        // Then
        #expect(router.calls == [.requestedDetail(.mockActive)])
    }

    @Test func openARecentlyDeletedEventThenRequestsRecoveryWithTheEventHighlighted() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(
            events: .init(storedEvents: [.mockDeleted(id: .mockDeleted)]),
            router: router
        )
        viewModel.reload()

        // When
        viewModel.open(.event(.mockDeleted))

        // Then
        #expect(router.calls == [.requestedSettings(.recentlyDeleted(highlighting: .mockDeleted))])
    }

    @Test func openAnUnknownEventThenChangesNothing() {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(
            events: .init(storedEvents: [.mock(id: .mockActive)]),
            router: router
        )
        viewModel.reload()
        viewModel.selectCategory(BuiltInCategory.birthday.id)

        // When
        viewModel.open(.event(.mockMissing))

        // Then
        #expect(router.calls.isEmpty)
        #expect(viewModel.filter.categoryID == BuiltInCategory.birthday.id)
    }

    @Test func openNewEventThenShowsTheEditorForTheShownCategory() {
        // Given
        let router = EventsRouterSpy()
        let birthday = EventCategory(builtIn: .birthday)
        let viewModel = makeViewModel(
            events: .init(storedEvents: [.mock(category: birthday)]),
            router: router
        )
        viewModel.reload()
        viewModel.selectCategory(birthday.id)

        // When
        viewModel.open(.newEvent)

        // Then
        #expect(router.calls == [.editor(.new(categoryID: birthday.id))])
    }

    @Test func openSearchThenPresentsSearch() {
        // Given
        let viewModel = makeViewModel()

        // When
        viewModel.open(.search)

        // Then
        #expect(viewModel.isSearchPresented)
    }

    @Test(arguments: [AppRequest.newEvent, .search])
    func openAKeyboardCommandWhileSelectingThenDoesNothing(request: AppRequest) {
        // Given
        let router = EventsRouterSpy()
        let viewModel = makeViewModel(router: router)
        viewModel.startSelecting()

        // When
        viewModel.open(request)

        // Then
        #expect(router.calls.isEmpty)
        #expect(!viewModel.isSearchPresented)
    }

    private func makeViewModel(
        events: EventRepositorySpy = .init(),
        categories: CategoryRepositorySpy = .init(),
        router: EventsRouterSpy = .init()
    ) -> HomeViewModel {
        .init(events: events, categories: categories, time: .mock(), router: router)
    }
}
