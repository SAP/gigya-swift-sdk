//
//  LogChannel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class LogChannel: BaseChannel {

    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.ignitionChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum LogChannelEvent: String {
    case debug
    case error
}
