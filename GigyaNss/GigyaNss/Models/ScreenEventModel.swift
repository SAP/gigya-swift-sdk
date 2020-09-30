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
}

public typealias EventFieldClosure = ((_ oldVal: String, _ newVal: String) -> Void)
public protocol ScreenContinueProtocol {

    func `continue`()
}

public protocol ScreenFieldProtocol {
    var fieldEvents: [String: EventFieldClosure] { get set }
}

public protocol ScreenNextProtocol {
    var nextRoute: String { get set }
}

public protocol ScreenError {
    func showError(_ e: String)
}

class ScreenEventModel: ScreenPreviousProtocol, ScreenDataProtocol, ScreenNextProtocol, ScreenError, ScreenContinueProtocol, ScreenFieldProtocol {

    var engineResponse: FlutterResult?

    var nextRoute: String = ""

    var previousRoute: String = ""

    var data: [String: Any] = [:]

    var fieldEvents: [String: EventFieldClosure] = [:]

    func `continue`() {
        engineResponse?(["sid": nextRoute, "data": data])
    }

    func showError(_ e: String) {
        engineResponse?(["error": e])
    }
}

public struct FieldEventModel {
    public var id: String
    public let oldVal: String?
    public let newVal: String?
}
