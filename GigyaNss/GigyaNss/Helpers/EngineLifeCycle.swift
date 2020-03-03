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

    init(ignitionChannel: IgnitionChannel, loaderHelper: LoaderFileHelper) {
        self.ignitionChannel = ignitionChannel
        self.loaderHelper = loaderHelper
    }

    func regToIgnitionChannel<T: GigyaAccountProtocol>(asset: String?, presentFrom vc: UIViewController, to screen: NativeScreenSetsViewController<T>) {
        guard let assetName = asset, !assetName.isEmpty else {
            GigyaLogger.error(with: EngineLifeCycle.self, message: "asset is empty.")
        }

        ignitionChannel.initChannel(engine: screen.engine!)

        ignitionChannel.methodHandler(scheme: IgnitionChannelEvent.self) { (method, data, response) in
            guard let method = method else {
                return
            }

            switch method {
            case .ignition:
                let loadAsset = self.loaderHelper.fileToDic(name: assetName)
                response(loadAsset)
            case .readyForDisplay:
                vc.present(screen, animated: true, completion: nil)
            }
        }
    }

    func regToLifeCircleOf<T: GigyaAccountProtocol>(vc: NativeScreenSetsViewController<T>) {
        vc.viewModel?.dismissClosure = { [weak vc] in
            vc?.dismiss(animated: true, completion: { [weak vc] in
                vc?.engine?.destroyContext()
                vc?.viewModel = nil
            })
        }

        // Close by swipe down event ( for iOS 13+ )
        vc.viewModel?.closeClosure = { [weak vc] in
            vc?.engine?.destroyContext()
            vc?.viewModel = nil
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "dinit")
    }
}
