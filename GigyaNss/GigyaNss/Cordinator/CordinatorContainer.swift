//
//  CordinatorContainer.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Gigya

class CordinatorContainer<T: GigyaAccountProtocol>: NSObject {
    private var flows = OrderedDictionary<Flow, NssFlow>()

    private var _currentFlow: Flow?

    var currentFlow: NssFlow? {
        guard let currentFlow = _currentFlow, let flow = flows[currentFlow] else {
            return nil
        }

        return flow
    }

    func add(id: Flow, flow: NssFlow) {
        flows[id] = flow

        _currentFlow = id
    }

    func remove(id: Flow) {
        flows.removeValueForKey(key: id)

        _currentFlow = flows.keys.last
    }

    func removeAll() {
        flows.removeAll(keepCapacity: 0)
        _currentFlow = nil
    }


}
