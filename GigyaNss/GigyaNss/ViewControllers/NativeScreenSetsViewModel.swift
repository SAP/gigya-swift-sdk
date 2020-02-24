//
//  NativeScreenSetsViewModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class NativeScreenSetsViewModel<T: GigyaAccountProtocol>: CordinatorContainer<T> {

    var mainChannel: MainPlatformChannelHandler?
    var apiChannel: ApiChannelHandler?

    func loadChannels(with engine: FlutterEngine) {
        mainChannel = MainPlatformChannelHandler(engine: engine)
        apiChannel = ApiChannelHandler(engine: engine)

        mainChannel?.methodHandler(scheme: MainMethodsChannelEvents.self) { (method, data, response ) in
            guard let method = method else {
                assertionFailure("Runtime error")
                return
            }

            switch method {
            case .initialize:
                response(self.loadJson())
            case .flow:
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
