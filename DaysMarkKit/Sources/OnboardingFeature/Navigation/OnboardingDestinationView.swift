//
//  OnboardingDestinationView.swift
//  OnboardingFeature
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

struct OnboardingDestinationView: FeatureDestinationView {
    let destination: OnboardingDestination

    var body: some View {
        switch destination {
        case .root: EmptyView()
        }
    }
}
