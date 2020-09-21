//
//  EventsHandlersManager.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 07/09/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation

struct EventsClosuresManager {
    var closures: [String: (NssScreenEvent) -> Void] = [:]

    subscript(id: String) -> ((NssScreenEvent) -> Void)? {
        get {
            return closures[id]
        }

        set {
            closures[id] = newValue
        }
    }
}
