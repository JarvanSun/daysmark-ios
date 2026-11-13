//
//  LocalizationCatalog.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/11/12.
//

import Foundation

struct LocalizationCatalog: Decodable {
    private let sourceLanguage: String
    private let strings: [String: Entry]

    var keysNotSemantic: [String] {
        keys { key, entry in entry.isTranslatable && !isSemantic(key) }
    }

    var keysWithoutComment: [String] {
        keys { _, entry in entry.comment?.isEmpty ?? true }
    }

    init(contentsOf url: URL) throws {
        self = try JSONDecoder().decode(LocalizationCatalog.self, from: Data(contentsOf: url))
    }

    func keysMissingValue(in language: String) -> [String] {
        keys { key, entry in
            let isImplicit = language == sourceLanguage && !isSemantic(key)

            return entry.isTranslatable && !isImplicit && !entry.hasValue(in: language)
        }
    }

    func keysWithPluralCategories(otherThan categories: Set<String>, in language: String)
        -> [String]
    {
        keys { _, entry in entry.pluralCategories(in: language).map { $0 != categories } ?? false }
    }

    private func isSemantic(_ key: String) -> Bool {
        key.wholeMatch(of: semanticKey) != nil
    }

    private var semanticKey: Regex<Substring> {
        /[a-z][A-Za-z0-9]*(?:\.[a-z][A-Za-z0-9]*)+(?: (?:%@|%lld|\$\{[A-Za-z]+\}))*/
    }

    private func keys(where isIncluded: (String, Entry) -> Bool) -> [String] {
        strings.filter { isIncluded($0.key, $0.value) }.map(\.key).sorted()
    }
}

extension LocalizationCatalog {
    private struct Entry: Decodable {
        let comment: String?
        let shouldTranslate: Bool?
        let localizations: [String: Localization]?

        var isTranslatable: Bool { shouldTranslate ?? true }

        func hasValue(in language: String) -> Bool {
            localizations?[language]?.hasValue ?? false
        }

        func pluralCategories(in language: String) -> Set<String>? {
            localizations?[language]?.variations?.plural.map { Set($0.keys) }
        }
    }

    private struct Localization: Decodable {
        let stringUnit: StringUnit?
        let stringSet: StringSet?
        let variations: Variations?

        var hasValue: Bool {
            let values = [stringUnit?.value].compactMap(\.self) + (stringSet?.values ?? [])
            let variants = variations?.localizations ?? []

            return switch variants.isEmpty {
            case true: !values.isEmpty && values.allSatisfy { !$0.isEmpty }
            case false: variants.allSatisfy(\.hasValue)
            }
        }
    }

    private struct Variations: Decodable {
        let plural: [String: Localization]?
        let device: [String: Localization]?

        var localizations: [Localization] {
            Array((plural ?? [:]).values) + Array((device ?? [:]).values)
        }
    }

    private struct StringUnit: Decodable {
        let value: String
    }

    private struct StringSet: Decodable {
        let values: [String]
    }
}
