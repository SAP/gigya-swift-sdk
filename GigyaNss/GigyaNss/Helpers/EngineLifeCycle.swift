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
                var loadAsset = self.loaderHelper.fileToDic(name: assetName)
                if let initialRoute = initialRoute {
                    var markup = loadAsset["markup"] as! [String: Any]
                    markup["initialRoute"] = initialRoute
                    loadAsset["markup"] = markup
                }

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
