//
//  LabelExtensions.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SunUserInterface
import SwiftUI

extension Label where Title == Text, Icon == Image {
    public init(_ title: Text, symbol: DaysMarkImage) {
        self.init {
            title
        } icon: {
            Image(style: symbol)
        }
    }
}
