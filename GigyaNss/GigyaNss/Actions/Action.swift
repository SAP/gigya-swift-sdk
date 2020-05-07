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
    var actionId: NssAction? { get set }

    var delegate: FlowManagerDelegate? { get set }

    func initialize(response: @escaping FlutterResult)

    func next(method: ApiChannelEvent, params: [String: Any]?)
}

class Action<T: GigyaAccountProtocol>: NssActionProtocol {
    var actionId: NssAction?

    weak var delegate: FlowManagerDelegate?

    func initialize(response: @escaping FlutterResult) {
        response([:])
    }

    func next(method: ApiChannelEvent, params: [String : Any]?) {
        switch method {
        case .api:
            break
        default:
            break
        }
    }

    lazy var apiClosure: (GigyaApiResult<T>) -> Void = { [weak self] result in
        let mainClosure = self?.delegate?.getMainLoginClosure(obj: T.self)

        switch result {
        case .success(let data):
            mainClosure?(.success(data: data))
        case .failure(let error):
            let loginError = LoginApiError<T>(error: error, interruption: nil)

            mainClosure?(.failure(loginError))
        }
    }
}
