//
//  BindingExtensions.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

extension Binding {
    public init(_ value: Value, onChange: @escaping (Value) -> Void) {
        self.init(get: { value }, set: { onChange($0) })
    }
}

extension Binding where Value == Bool {
    public init<Presented>(isPresenting value: Presented?, onDismiss: @escaping () -> Void) {
        self.init(
            get: { value != nil },
            set: { isPresented in
                guard !isPresented else { return }

                onDismiss()
            }
        )
    }
}
