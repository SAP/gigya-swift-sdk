//
//  NssFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

protocol NssActionProtocol: class {

    var delegate: FlowManagerDelegate? { get set }

    func initialize(response: @escaping FlutterResult)

    func next(method: ApiChannelEvent, params: [String: Any]?)
}

class NssAction<T: GigyaAccountProtocol>: NssActionProtocol {

    weak var delegate: FlowManagerDelegate?

    func initialize(response: @escaping FlutterResult) {
        response([:])
    }

    func next(method: ApiChannelEvent, params: [String : Any]?) {}
}
