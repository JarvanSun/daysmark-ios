//
//  WidgetConfigurationMetadataTests.swift
//  DaysMarkTests
//
//  Created by Jiawen Sun on 2026/09/05.
//

import Foundation
import Testing

struct WidgetConfigurationMetadataTests {
    @Test
    func shippedDefaultsRemainDistinct() throws {
        let plugins = try #require(Bundle.main.builtInPlugInsURL)
        let url = plugins.appending(
            path: "DaysMarkWidgetExtension.appex/Metadata.appintents/extract.actionsdata"
        )
        let root = try #require(
            JSONSerialization.jsonObject(with: Data(contentsOf: url)) as? [String: Any]
        )
        let actions = try #require(root["actions"] as? [String: [String: Any]])
        for (intent, expected) in [
            ("CountdownWidgetConfigurationIntent", "automaticFocus"),
            ("CountdownListWidgetConfigurationIntent", "allEvents"),
        ] {
            let action = try #require(actions[intent])
            let parameters = try #require(action["parameters"] as? [[String: Any]])
            #expect(
                Set(parameters.compactMap { $0["name"] as? String }) == [
                    "source", "event", "category",
                ]
            )
            let source = try #require(parameters.first { $0["name"] as? String == "source" })
            let metadata = try #require(source["typeSpecificMetadata"] as? [Any])
            let keyIndex = try #require(
                metadata.firstIndex {
                    $0 as? String == "LNValueTypeSpecificMetadataKeyDefaultValue"
                }
            )
            let value = try #require(metadata.dropFirst(keyIndex + 1).first as? [String: Any])
            let string = try #require(value["string"] as? [String: String])
            #expect(string["wrapper"] == expected)
        }
    }
}
