//
//  IssueAlertModifier.swift
//  DesignSystem
//
//  Created by Jiawen Sun on 2026/11/12.
//

import SwiftUI

public protocol IssuePresenting {
    var title: LocalizedStringResource { get }
    var message: LocalizedStringResource? { get }
}

struct IssueAlertModifier<Issue: IssuePresenting, Actions: View>: ViewModifier {
    let issue: Issue?
    let onDismiss: () -> Void
    let actions: (Issue) -> Actions

    func body(content: Content) -> some View {
        content.alert(
            title,
            isPresented: Binding(isPresenting: issue, onDismiss: onDismiss),
            presenting: issue,
            actions: actions,
            message: { issue in
                if let message = issue.message {
                    Text(message)
                }
            }
        )
    }

    private var title: Text {
        switch issue {
        case .some(let issue): Text(issue.title)
        case nil: Text(verbatim: "")
        }
    }
}

extension View {
    public func alert<Issue: IssuePresenting, Actions: View>(
        issue: Issue?,
        onDismiss: @escaping () -> Void,
        @ViewBuilder actions: @escaping (Issue) -> Actions
    ) -> some View {
        modifier(IssueAlertModifier(issue: issue, onDismiss: onDismiss, actions: actions))
    }

    public func alert<Issue: IssuePresenting>(
        issue: Issue?,
        onDismiss: @escaping () -> Void
    ) -> some View {
        alert(issue: issue, onDismiss: onDismiss) { _ in
            Button(role: .cancel, action: onDismiss) {
                Text("issueAlert.confirm", bundle: .module)
            }
        }
    }
}

#if DEBUG
#Preview {
    Color.clear
        .background(DaysMarkColor.canvas.color.ignoresSafeArea())
        .alert(issue: PreviewObjectPool().issue, onDismiss: {})
}
#endif
