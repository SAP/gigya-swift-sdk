//
//  ScreenSetsBuilder.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 20/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Gigya

// MARK: - Main builder options

class ScreenSetsBuilder<T: GigyaAccountProtocol>: ScreenSetsMainBuilderProtocol {

    var assetName: String?
    var screenName: String?

    @discardableResult
    func load(withAsset asset: String) -> BuilderOptions {
        assetName = asset
        return self
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
        guard let assetName = assetName, !assetName.isEmpty else {
            GigyaLogger.error(with: ScreenSetsBuilder.self, message: "screenSetName is empty, please use `setScreen(name: String)` before using `show()`.")
        }
        
        // TODO: How to check if the screenSetId is exists? Maybe need to check it in the flutter engine?

        guard let screenSetViewController = GigyaNss.dependenciesContainer.resolve(NativeScreenSetsViewController<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "`NativeScreenSetsViewController` dependency not found.")
        }

        // build the screen with the asset
        screenSetViewController.build(asset: assetName)

        viewController.present(screenSetViewController, animated: true, completion: nil)
        

    }
}
