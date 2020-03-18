//
//  NssFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

protocol NssFlowProtocol {
    func initialize(response: @escaping FlutterResult)

    func next(method: ApiChannelEvent, params: [String: Any]?, response: @escaping FlutterResult)
}

class NssFlow: NssFlowProtocol {
    func initialize(response: @escaping FlutterResult) {
        response([:])
    }

    func next(method: ApiChannelEvent, params: [String : Any]?, response: @escaping FlutterResult) {}
}
