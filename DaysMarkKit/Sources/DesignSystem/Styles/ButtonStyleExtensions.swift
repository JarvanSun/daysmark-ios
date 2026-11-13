//
//  ButtonStyleExtensions.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension PrimitiveButtonStyle where Self == DaysMarkButtonStyle {
    public static func daysmark(_ kind: DaysMarkButtonStyle.Kind) -> Self {
        DaysMarkButtonStyle(kind: kind)
    }
}
