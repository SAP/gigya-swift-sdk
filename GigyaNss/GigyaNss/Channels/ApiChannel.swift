//
//  ApiChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class ApiChannel: BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.apiChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum ApiChannelEvent: String {
    case submit
    case api
}
//struct ApiChannelEvent: RawRepresentable {
//    var rawValue: String
//
//    init(rawValue: String) {
//        self.rawValue = rawValue
//    }
//}
