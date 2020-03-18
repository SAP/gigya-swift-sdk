//
//  AccountFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import Gigya
import Flutter

class AccountFlow<T: GigyaAccountProtocol>: NssFlow {
    var busnessApi: BusinessApiDelegate

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    override func initialize(response: @escaping FlutterResult) {
        busnessApi.callGetAccount(dataType: T.self, params: [:]) { (result) in
            
        }
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?, response: @escaping FlutterResult) {
        switch method {
        case .submit:
            break
        default:
            break
        }
    }
}
