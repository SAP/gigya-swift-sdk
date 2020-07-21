//
//  IgnitionChannel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 01/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

class IgnitionChannel: BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.ignitionChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum IgnitionChannelEvent: String {
    case ignition
    case readyForDisplay = "ready_for_display"
    case loadSchema = "load_schema"
}
