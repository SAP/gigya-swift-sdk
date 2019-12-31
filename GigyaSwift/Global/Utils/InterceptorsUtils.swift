//
//  InterceptorsUtils.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 29/12/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public class InterceptorsUtils {
    private var handlers: [String: () -> ()] = [:]

    func add(key: String, handler: @escaping () -> ()) {
        handlers[key] = handler
    }

    func runAll() {
        handlers.forEach { (handler) in
            handler.value()
        }
    }
}
