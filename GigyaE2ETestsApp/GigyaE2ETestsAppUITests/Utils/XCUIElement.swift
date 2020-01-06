//
//  XCUIElement.swift
//  GigyaE2ETestsAppUITests
//
//  Created by Shmuel, Sagi on 31/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElement {
    func clearText() {
        guard let stringValue = self.value as? String else {
            return
        }

        var deleteString = String()
        for _ in stringValue {
            deleteString += XCUIKeyboardKey.delete.rawValue
        }
        typeText(deleteString)
    }
}
