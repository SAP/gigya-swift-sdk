//
//  MainPlatformChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter

class MainPlatformChannelHandler {

    let flutterMethodChannel: FlutterMethodChannel

    init(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: "gigya_nss_engine/method/platform", binaryMessenger: engine.binaryMessenger)

        activateHandler()
    }

    func activateHandler() {
        flutterMethodChannel.setMethodCallHandler { (call, result) in
            let method = MethodsChannel(rawValue: call.method)

            switch method {
            case .engineInit:
                result(["responseId": "engineInit"])
            default:
                break
            }
        }
    }
}

enum MethodsChannel: String {
    case engineInit
}
