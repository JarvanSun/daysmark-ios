//
//  ContactBirthdayScanner.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Contacts
import Foundation

@MainActor
struct ContactBirthdayScanner {
    func scan(now: Date, timeZone: TimeZone) async throws -> [ImportedDate] {
        let store = CNContactStore()
        try await requestAccess(to: store)

        let request = CNContactFetchRequest(keysToFetch: [
            CNContactIdentifierKey as CNKeyDescriptor,
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactNonGregorianBirthdayKey as CNKeyDescriptor,
        ])
        var birthdays: [ImportedDate] = []

        try store.enumerateContacts(with: request) { contact, _ in
            guard let birthday = importedBirthday(of: contact, now: now, timeZone: timeZone) else {
                return
            }

            birthdays.append(birthday)
        }

        return birthdays.sorted {
            $0.title.localizedStandardCompare($1.title) == .orderedAscending
        }
    }

    private func requestAccess(to store: CNContactStore) async throws {
        switch ImportAccess(CNContactStore.authorizationStatus(for: .contacts)) {
        case .granted:
            break
        case .denied:
            throw ImportError.permissionDenied
        case .undetermined:
            guard (try? await store.requestAccess(for: .contacts)) == true else {
                throw ImportError.permissionDenied
            }
        }
    }

    private func importedBirthday(of contact: CNContact, now: Date, timeZone: TimeZone)
        -> ImportedDate?
    {
        guard var birthday = contact.birthday ?? contact.nonGregorianBirthday,
            birthday.month != nil,
            birthday.day != nil
        else { return nil }

        var sourceCalendar = birthday.calendar ?? Calendar(identifier: .gregorian)
        sourceCalendar.timeZone = timeZone
        birthday.calendar = sourceCalendar

        guard let date = birthdayDate(birthday, calendar: sourceCalendar, now: now) else {
            return nil
        }

        return ImportedDate(
            sourceKind: .contacts,
            sourceIdentifier: contact.identifier,
            title: title(for: contact),
            date: date,
            repeatsYearly: true,
            calendarSystem: EventCalendarSystem(supporting: sourceCalendar.identifier),
            timeZone: timeZone,
            includesTime: false
        )
    }

    func birthdayDate(_ birthday: DateComponents, calendar: Calendar, now: Date) -> Date? {
        var components = birthday
        components.calendar = nil
        components.timeZone = nil

        guard components.year == nil else { return calendar.strictDate(from: components) }

        let currentYear = calendar.component(.year, from: now)
        components.era = calendar.component(.era, from: now)

        for offset in 0...8 {
            components.year = currentYear - offset

            if let date = calendar.strictDate(from: components) {
                return date
            }
        }

        return nil
    }

    private func title(for contact: CNContact) -> String {
        let name = CNContactFormatter.string(from: contact, style: .fullName) ?? ""

        return switch name.isEmpty {
        case true: String(localized: "import.contacts.birthday.unnamed", bundle: .module)
        case false: String(localized: "import.contacts.birthday \(name)", bundle: .module)
        }
    }
}
