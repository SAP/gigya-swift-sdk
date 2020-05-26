//
//  MainPlatformChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class ScreenChannel: BaseChannel {

    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.screenChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum ScreenChannelEvent: String {
    case action
    case dismiss = "_dismiss"
    case canceled = "_canceled"
}
