//
//  EngineLifeCycle.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 03/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import UIKit
import Gigya
import Flutter

class EngineLifeCycle {
    private let ignitionChannel: IgnitionChannel

    let loaderHelper: LoaderFileHelper

    private let schemaHelper: SchemaHelper

    private var isDisplay = false

    private var response: FlutterResult?

    init(ignitionChannel: IgnitionChannel, loaderHelper: LoaderFileHelper, schemaHelper: SchemaHelper) {
        self.ignitionChannel = ignitionChannel
        self.loaderHelper = loaderHelper
        self.schemaHelper = schemaHelper
    }

    func register<T: GigyaAccountProtocol>(asset: ScreenLoadType?,
                                                       initialRoute: String?,
                                                       defaultLang: String?,
                                                       presentFrom vc: UIViewController,
                                                       to screen: NativeScreenSetsViewController<T>) {
        guard let asset = asset else {
            GigyaLogger.error(with: EngineLifeCycle.self, message: "asset is empty.")
        }

        regToLifeCircleOf(vc: screen)

        ignitionChannel.initChannel(engine: screen.engine!)

        ignitionChannel.methodHandler(scheme: IgnitionChannelEvent.self) { [weak self, weak screen] (method, data, response) in
            guard let self = self, let method = method else {
                return
            }

            switch method {
            case .ignition:
                GigyaLogger.log(with: self, message: "ignition start")

                self.loaderHelper.load(asset: asset, defaultLang: defaultLang) { (data) in
                    var loadAsset = data

                    if let initialRoute = initialRoute {
                        guard var routing = loadAsset["routing"] as? [String: Any] else {
                            GigyaLogger.error(with: EngineLifeCycle.self, message: "parsing error - `routing` is not exists.")
                        }

                        routing["initial"] = initialRoute
                        loadAsset["routing"] = routing
                    }

                    GigyaLogger.log(with: self, message: "ignition screen load: \(loadAsset)")

                    response(loadAsset)
                }

            case .readyForDisplay:
                if self.isDisplay {
                    return
                }

                self.isDisplay = true

                screen?.removeSpinner()

            case .loadSchema:
                self.schemaHelper.getSchema { (data) in
                    response(data)
                }
            }
        }

        vc.present(screen, animated: true, completion: nil)
    }

    func regToLifeCircleOf<T: GigyaAccountProtocol>(vc: NativeScreenSetsViewController<T>) {
        vc.viewModel?.dismissClosure = { [weak vc] in
            vc?.dismiss(animated: true, completion: { [weak vc, weak self] in
                self?.destroyContext(vc)
            })
        }

        // Close by swipe down event ( for iOS 13+ )
        vc.viewModel?.closeClosure = { [weak vc, weak self] in
            self?.destroyContext(vc)
        }

        loaderHelper.errorClosure = { [weak vc, weak self] error in
            vc?.viewModel?.eventHandler?(NssEvents.error(screenId: "", error: error))
            self?.destroyContext(vc)
        }
    }

    func destroyContext<T: GigyaAccountProtocol>(_ vc: NativeScreenSetsViewController<T>?) {
        vc?.removeSpinner()
        vc?.viewModel = nil
        self.isDisplay = false
    }

    deinit {
        GigyaLogger.log(with: self, message: "dinit")
    }
}
