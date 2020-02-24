//
//  CordinatorContainer.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Gigya

class CordinatorContainer<T: GigyaAccountProtocol> {
    private var flows = OrderedDictionary<String, NssFlow<T>>()

    private var _currentFlow: String?

    var currentFlow: String? {
        return _currentFlow
    }

    func add(id: String, flow: NssFlow<T>) {
        flows[id] = flow

        _currentFlow = id
    }

    func remove(id: String) {
        flows.removeValueForKey(key: id)

        _currentFlow = flows.keys.last
    }


}
