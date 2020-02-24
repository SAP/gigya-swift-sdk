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

    var dismissClosure: () -> Void = {}

    var mainChannel: MainPlatformChannelHandler?
    var apiChannel: ApiChannelHandler?

    let loaderHelper: LoaderFileHelper

    let engineBundle = "Gigya.GigyaNssEngine"
    let engineId = "io.flutter"

    init(loaderHelper: LoaderFileHelper) {
        self.loaderHelper = loaderHelper
    }

    func createEngine() -> FlutterEngine {
        let bundle = Bundle(identifier: engineBundle)
        let project = FlutterDartProject(precompiledDartBundle: bundle)

        let engine = FlutterEngine(name: engineId, project: project)
        engine.run()

        return engine
    }
    
    func loadChannels(with engine: FlutterEngine, asset: String) {
        mainChannel = MainPlatformChannelHandler(engine: engine)
        apiChannel = ApiChannelHandler(engine: engine)

        mainChannel?.methodHandler(scheme: MainMethodsChannelEvents.self) { (method, data, response ) in
            print("method: \(method)")
            switch method {
            case .ignition:
                let loadAsset = self.loaderHelper.fileToDic(name: asset)
                response(loadAsset)
            case .flow:
                break
            case .dismiss:
                self.dismissClosure()
            case .none:
                break
            }

        }
    }

    func loadJson(asset: String) -> [String: Any] {
        if let filePath = Bundle.main.url(forResource: asset, withExtension: "json") {
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
