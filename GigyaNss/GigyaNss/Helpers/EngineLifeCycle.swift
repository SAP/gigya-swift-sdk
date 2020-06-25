//
//  EngineLifeCycle.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 03/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import UIKit
import Gigya

class EngineLifeCycle {
    private let ignitionChannel: IgnitionChannel

    private let loaderHelper: LoaderFileHelper

    private var isDisplay = false

    init(ignitionChannel: IgnitionChannel, loaderHelper: LoaderFileHelper) {
        self.ignitionChannel = ignitionChannel
        self.loaderHelper = loaderHelper
    }

    func register<T: GigyaAccountProtocol>(asset: String?,
                                                       initialRoute: String?,
                                                       presentFrom vc: UIViewController,
                                                       to screen: NativeScreenSetsViewController<T>) {
        guard let assetName = asset, !assetName.isEmpty else {
            GigyaLogger.error(with: EngineLifeCycle.self, message: "asset is empty.")
        }

        regToLifeCircleOf(vc: screen)

        ignitionChannel.initChannel(engine: screen.engine!)

        ignitionChannel.methodHandler(scheme: IgnitionChannelEvent.self) { (method, data, response) in
            guard let method = method else {
                return
            }

            switch method {
            case .ignition:
                GigyaLogger.log(with: self, message: "ignition start")

                // load the `screenSets` file from bundle. (example: `init.json`)
                var loadAsset = self.loaderHelper.fileToDic(name: assetName)
                
                // load the `theme` file from bundle. (example: `init.theme.json`)
                let loadTheme = self.loaderHelper.fileToDic(name: "\(assetName).theme")

                if let initialRoute = initialRoute {
                    guard var assetJson = loadAsset, var routing = assetJson["routing"] as? [String: Any] else {
                        GigyaLogger.error(with: EngineLifeCycle.self, message: "parsing error - `routing` is not exists.")
                    }
                    
                    routing["initial"] = initialRoute
                    assetJson["routing"] = routing

                    if let theme = loadTheme {
                        assetJson["theme"] = theme
                    }

                    loadAsset = assetJson
                }

                GigyaLogger.log(with: self, message: "ignition screen load: \(loadAsset ?? [:])")

                response(loadAsset)
            case .readyForDisplay:
                if self.isDisplay {
                    return
                }

                self.isDisplay = true
                vc.present(screen, animated: true, completion: nil)
            }
        }
    }

    func regToLifeCircleOf<T: GigyaAccountProtocol>(vc: NativeScreenSetsViewController<T>) {
        vc.viewModel?.dismissClosure = { [weak vc] in
            vc?.dismiss(animated: true, completion: { [weak vc, weak self] in
                vc?.engine?.destroyContext()
                vc?.viewModel = nil
                self?.isDisplay = false
            })
        }

        // Close by swipe down event ( for iOS 13+ )
        vc.viewModel?.closeClosure = { [weak vc, weak self] in
            vc?.engine?.destroyContext()
            vc?.viewModel = nil
            self?.isDisplay = false
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "dinit")
    }
}
