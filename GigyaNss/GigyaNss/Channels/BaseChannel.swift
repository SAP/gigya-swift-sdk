//
//  BaseChannel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 24/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

protocol BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel { get set }

    init(engine: FlutterEngine)
}

extension BaseChannel {
    func methodHandler<T: RawRepresentable>(scheme: T.Type, _ handler: @escaping (T?, Any?, FlutterResult) -> Void) where T.RawValue == String {
        flutterMethodChannel.setMethodCallHandler { (call, result) in
            let method = T(rawValue: call.method)
            print("method: \(call.method)")
            handler(method, call.arguments, result)
        }
    }
}
