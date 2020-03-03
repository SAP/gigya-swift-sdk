//
//  ScreenSetsBuilder.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 20/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Gigya
import Flutter

// MARK: - Main builder options

class ScreenSetsBuilder<T: GigyaAccountProtocol>: ScreenSetsMainBuilderProtocol {
    let engineLifeCycle: EngineLifeCycle

    var assetName: String?
    var screenName: String?


    init(engineLifeCycle: EngineLifeCycle) {
        self.engineLifeCycle = engineLifeCycle
    }

    @discardableResult
    func load(withAsset asset: String) -> BuilderOptions {
        assetName = asset
        return self
    }

    deinit {
        GigyaLogger.log(with: ScreenSetsBuilder.self, message: "dinit")
    }
}

extension ScreenSetsBuilder: ScreenSetsExternalBuilderProtocol {
    func setScreen(name: String) -> BuilderOptions {
        screenName = name
        return self
    }
}

// MARK: - Builder actions

extension ScreenSetsBuilder: ScreenSetsActionsBuilderProtocol {
    func show(viewController: UIViewController) {
        guard let screenName = screenName else {
            GigyaLogger.error(with: ScreenSetsBuilder.self, message: "screenSetName is empty, please use `setScreen(name: String)` before using `show()`.")
        }
        
        // TODO: How to check if the screenSetId is exists? Maybe need to check it in the flutter engine?
        guard let screenSetViewController = GigyaNss.shared.dependenciesContainer.resolve(NativeScreenSetsViewController<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "`NativeScreenSetsViewController` dependency not found.")
        }

        // build the screen with the asset
        screenSetViewController.build(initialRoute: screenName)
        screenSetViewController.presentationController?.delegate = screenSetViewController.viewModel

        engineLifeCycle.regToIgnitionChannel(asset: assetName, presentFrom: viewController, to: screenSetViewController)

        engineLifeCycle.regToLifeCircleOf(vc: screenSetViewController)
    }
}
