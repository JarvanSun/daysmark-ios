//
//  ImportantDateIntentErrorTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import DaysMarkCore
import Testing

@testable import DaysMark

struct ImportantDateIntentErrorTests {
    @Test func initThenMapsEveryEventErrorToWhatSiriSays() {
        // Given / When / Then
        #expect(ImportantDateIntentError(.emptyTitle) == .emptyTitle)
        #expect(ImportantDateIntentError(.invalidDraft) == .invalidDate)
        #expect(ImportantDateIntentError(.permanentlyDeleted) == .permanentlyDeleted)
        #expect(ImportantDateIntentError(.inRecentlyDeleted) == .inRecentlyDeleted)
        #expect(ImportantDateIntentError(.localStoreUnavailable) == .storageUnavailable)
        #expect(ImportantDateIntentError(.eventUnavailable) == .actionFailed)
        #expect(ImportantDateIntentError(.storeFailure) == .actionFailed)
    }

    @Test func errorDescriptionThenIsTheSentenceSiriSpeaks() {
        // Given / When / Then
        #expect(ImportantDateIntentError.emptyTitle.errorDescription == "An event needs a title.")
        #expect(
            ImportantDateIntentError.invalidDate.errorDescription
                == "Check the event date and reminder settings."
        )
        #expect(
            ImportantDateIntentError.permanentlyDeleted.errorDescription
                == "This event was permanently deleted."
        )
        #expect(
            ImportantDateIntentError.inRecentlyDeleted.errorDescription
                == "This event is in Recently Deleted. Restore it to make changes."
        )
        #expect(
            ImportantDateIntentError.storageUnavailable.errorDescription
                == "Local import storage is unavailable."
        )
        #expect(
            ImportantDateIntentError.actionFailed.errorDescription == "Couldn’t complete the action"
        )
    }
}
