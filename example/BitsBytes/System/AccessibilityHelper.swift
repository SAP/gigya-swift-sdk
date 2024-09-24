//
//  AccessibilityHelper.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 21/07/2024.
//

import SwiftUI

struct AccessibilityId: ViewModifier {
    let label: String
    let clazz: String

    func body(content: Content) -> some View {

        content
            .accessibilityIdentifier("\(clazz)_\(label)")
    }
}

extension View {
    func accessibilityId<T: View>(_ tag: T, _ label: String) -> some View {
        let clazz = String(describing: type(of: T.self))
            .replacingOccurrences(of: ".Type", with: "")
        return modifier(AccessibilityId(label: label, clazz: clazz))
    }
}
