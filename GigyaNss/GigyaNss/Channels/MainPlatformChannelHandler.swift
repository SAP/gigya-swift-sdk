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
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.mainChannel, binaryMessenger: engine.binaryMessenger)

        activateHandler()
    }

    func activateHandler() {
        flutterMethodChannel.setMethodCallHandler { (call, result) in
            let method = MainMethodsChannelEvents(rawValue: call.method)

            switch method {
            case .engineInit:
                result(["responseId": "engineInit"])
            default:
                break
            }
        }
    }
}

enum MainMethodsChannelEvents: String {
    case engineInit
}
