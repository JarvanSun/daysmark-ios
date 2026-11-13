//
//  RenderedEventShareCard.swift
//  EventsFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import CoreTransferable
import UIKit
import UniformTypeIdentifiers

struct RenderedEventShareCard {
    let image: UIImage
    let transferable: SharedEventCard
}

nonisolated struct SharedEventCard: Transferable {
    let pngData: Data

    static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { $0.pngData }
    }
}
