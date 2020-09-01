//
//  DataChannel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 12/08/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class DataChannel: BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.dataChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum DataChannelEvent: String {
    case imageResource = "image_resource"
    case pickImage = "pick_image"

}
