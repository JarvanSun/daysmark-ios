//
//  AppRequest.swift
//  DaysMarkCore
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

public enum AppRequest: Hashable, Sendable {
    case event(UUID)
    case category(UUID)
    case collection(Collection)
    case widgets
    case newEvent
    case search

    public init?(url: URL) {
        guard url.scheme?.lowercased() == Word.scheme.rawValue else { return nil }
        guard url.query == nil, url.fragment == nil else { return nil }

        let host = url.host.flatMap { Host(rawValue: $0.lowercased()) }
        let words = url.pathComponents.filter { $0 != Word.separator.rawValue }

        let request: AppRequest? =
            switch (host, words.count) {
            case (.event, 1): UUID(uuidString: words[0]).map(AppRequest.event)
            case (.category, 1): UUID(uuidString: words[0]).map(AppRequest.category)
            case (.collection, 1): Collection(rawValue: words[0]).map(AppRequest.collection)
            case (.widgets, 0): .widgets
            default: nil
            }

        guard let request else { return nil }

        self = request
    }

    public var url: URL? {
        switch self {
        case .event(let id): link(to: .event, id.uuidString)
        case .category(let id): link(to: .category, id.uuidString)
        case .collection(let collection): link(to: .collection, collection.rawValue)
        case .widgets: link(to: .widgets, nil)
        case .newEvent, .search: nil
        }
    }

    private func link(to host: Host, _ word: String?) -> URL? {
        var components = URLComponents()
        components.scheme = Word.scheme.rawValue
        components.host = host.rawValue
        components.path = word.map { Word.separator.rawValue + $0 } ?? ""

        return components.url
    }
}

extension AppRequest {
    public enum Collection: String, Hashable, Sendable {
        case all
        case birthdays
        case anniversaries

        public var categoryID: UUID? {
            switch self {
            case .all: nil
            case .birthdays: BuiltInCategory.birthday.id
            case .anniversaries: BuiltInCategory.anniversary.id
            }
        }
    }

    private enum Word: String {
        case scheme = "daysmark"
        case separator = "/"
    }

    private enum Host: String {
        case event
        case category
        case collection
        case widgets
    }
}
