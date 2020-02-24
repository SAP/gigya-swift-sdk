//
//  MainPlatformChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
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

            handler(method, call.arguments, result)
        }
    }
}

class MainPlatformChannelHandler: BaseChannel {

    var flutterMethodChannel: FlutterMethodChannel

    required init(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.mainChannel, binaryMessenger: engine.binaryMessenger)
    }
}

enum MainMethodsChannelEvents: String {
    case initialize
    case flow
}
