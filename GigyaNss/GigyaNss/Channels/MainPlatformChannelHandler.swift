//
//  MainPlatformChannelHandler.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 13/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter

class MainPlatformChannelHandler {

    let flutterMethodChannel: FlutterMethodChannel

    init(engine: FlutterEngine) {
        flutterMethodChannel = FlutterMethodChannel(name: GigyaNss.mainChannel, binaryMessenger: engine.binaryMessenger)

        activateHandler()
    }

    func activateHandler() {
        flutterMethodChannel.setMethodCallHandler { (call, result) in
            let method = MainMethodsChannelEvents(rawValue: call.method)

            switch method {
            case .initialize:
                let json = self.loadJson()

                result(json)
            default:
                break
            }
        }
    }

    func loadJson() -> [String: Any] {
        if let filePath = Bundle.main.url(forResource: "init", withExtension: "json") {
            do {
                let data = try Data(contentsOf: filePath, options: .mappedIfSafe)
                  let jsonResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                  if let jsonResult = jsonResult as? Dictionary<String, AnyObject> {
                            // do stuff
                    return jsonResult
                  }
              } catch {
                   // handle error
                return [:]
              }
        }

         return [:]
    }
}

enum MainMethodsChannelEvents: String {
    case initialize
}
