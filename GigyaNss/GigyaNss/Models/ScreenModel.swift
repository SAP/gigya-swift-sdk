//
//  ScreenRoute.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 06/09/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter

public protocol ScreenPreviousProtocol {
    var previousRoute: String { get }
}

public protocol ScreenDataProtocol {
    var data: [String: Any] { get set }

    func `continue`()
}

public protocol ScreenNextProtocol {
    var nextRoute: String { get set }
}

class ScreenModel: ScreenPreviousProtocol, ScreenDataProtocol, ScreenNextProtocol {

    var engineResponse: FlutterResult?

    var nextRoute: String = ""

    var previousRoute: String = ""

    var data: [String: Any] = [:]

    func `continue`() {
        engineResponse?(["sid": nextRoute, "data": data])
    }

    func showError(_ e: String) {
        engineResponse?(["error": e])
    }
}
