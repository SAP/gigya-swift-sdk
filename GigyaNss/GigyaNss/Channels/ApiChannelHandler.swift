//
//  ApiChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter

class ApiChannelHandler: BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel


    required init(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.apiChannel, binaryMessenger: engine.binaryMessenger)
    }

}
