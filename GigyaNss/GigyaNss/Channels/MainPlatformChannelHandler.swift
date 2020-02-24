//
//  MainPlatformChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class MainPlatformChannelHandler: BaseChannel {

    var flutterMethodChannel: FlutterMethodChannel

    required init(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.mainChannel, binaryMessenger: engine.binaryMessenger)
    }
}

enum MainMethodsChannelEvents: String {
    case ignition
    case flow
    case dismiss
}
