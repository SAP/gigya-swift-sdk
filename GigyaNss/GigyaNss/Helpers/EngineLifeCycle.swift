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

    private let schemaHelper: SchemaHelper

    private var isDisplay = false

    init(ignitionChannel: IgnitionChannel, loaderHelper: LoaderFileHelper, schemaHelper: SchemaHelper) {
        self.ignitionChannel = ignitionChannel
        self.loaderHelper = loaderHelper
        self.schemaHelper = schemaHelper
    }

    func register<T: GigyaAccountProtocol>(asset: String?,
                                                       initialRoute: String?,
                                                       defaultLang: String?,
                                                       presentFrom vc: UIViewController,
                                                       to screen: NativeScreenSetsViewController<T>) {
        guard let assetName = asset, !assetName.isEmpty else {
            GigyaLogger.error(with: EngineLifeCycle.self, message: "asset is empty.")
        }

        regToLifeCircleOf(vc: screen)

        ignitionChannel.initChannel(engine: screen.engine!)

        ignitionChannel.methodHandler(scheme: IgnitionChannelEvent.self) { [weak self] (method, data, response) in
            guard let self = self, let method = method else {
                return
            }

            switch method {
            case .ignition:
                GigyaLogger.log(with: self, message: "ignition start")

                // load the `screenSets` file from bundle. (example: `init.json`)
                guard var loadAsset = self.loaderHelper.fileToDic(name: assetName) else {
                    GigyaLogger.error(with: EngineLifeCycle.self, message: "parsing error ")
                }
                
                // load the `theme` file from bundle. (example: `init.theme.json`)
                let loadFileTheme = self.loaderHelper.fileToDic(name: "\(assetName).\(GigyaNss.themePrefix))")

                // load the `i18n` file from bundle. (example: `init.theme.json`)
                let loadLangFile = self.loaderHelper.fileToDic(name: "\(assetName).\(GigyaNss.langPrefix)")

                if let initialRoute = initialRoute {
                    guard var routing = loadAsset["routing"] as? [String: Any] else {
                        GigyaLogger.error(with: EngineLifeCycle.self, message: "parsing error - `routing` is not exists.")
                    }
                    
                    routing["initial"] = initialRoute
                    loadAsset["routing"] = routing
                }

                if let lang = defaultLang {
                    loadAsset["lang"] = lang
                }

                if let themeFile = loadFileTheme {
                    if let themeMap = themeFile["theme"] {
                        loadAsset["theme"] = themeMap
                    }

                    if let customThemes = themeFile["customThemes"] {
                         loadAsset["customThemes"] = customThemes
                     }
                }

                if let i18n = loadLangFile {
                    loadAsset["i18n"] = i18n
                }

                GigyaLogger.log(with: self, message: "ignition screen load: \(loadAsset)")

                response(loadAsset)
            case .readyForDisplay:
                if self.isDisplay {
                    return
                }

                self.isDisplay = true
                vc.present(screen, animated: true, completion: nil)
            case .loadSchema:
                self.schemaHelper.getSchema { (data) in
                    response(data)
                }
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
