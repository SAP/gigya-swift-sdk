//
//  EventsChannel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 06/09/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import Gigya
import Flutter

class EventsChannel: BaseChannel {
    var flutterMethodChannel: FlutterMethodChannel?

    func initChannel(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.eventsChannel, binaryMessenger: engine.binaryMessenger)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

enum EventsChannelEvent: String {
    case screenDidLoad
    case routeFrom
    case routeTo
    case submit
    case fieldDidChange
}

@frozen
public enum NssScreenEvent {
    case screenDidLoad
    case routeFrom(screen: ScreenPreviousProtocol & ScreenContinueProtocol & ScreenDataProtocol)
    case routeTo(screen: ScreenNextProtocol & ScreenContinueProtocol & ScreenDataProtocol)
    case submit(screen: ScreenContinueProtocol & ScreenDataProtocol & ScreenError)
    case fieldDidChange(screen: ScreenContinueProtocol & ScreenError & ScreenFieldProtocol, field: FieldEventModel) // TODO: need to understand how to handle it
}
