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

class ScreenSetsBuilder: ScreenSetsMainBuilderProtocol {

    let loaderHelper: LoaderFileHelper = LoaderFileHelper()

    var dataDictionary: [String: Any] = [:]
    var screenSetName: String?

    @discardableResult
    func load(withAsset asset: String) -> BuilderOptions {
        dataDictionary = loaderHelper.fileToDic(name: asset)
        return self
    }
}

extension ScreenSetsBuilder: ScreenSetsExternalBuilderProtocol {
    func setScreen(name: String) -> BuilderOptions {
        screenSetName = name
        return self
    }
}

// MARK: - Builder actions

extension ScreenSetsBuilder: ScreenSetsActionsBuilderProtocol {
    func show(viewController: UIViewController) {
        guard let screenSetName = screenSetName, !screenSetName.isEmpty else {
            GigyaLogger.error(with: ScreenSetsBuilder.self, message: "screenSetName is empty, please use `setScreen(name: String)` before using `show()`.")
        }
        // TODO: How to check if the screenSetId is exists? Maybe need to check it in the flutter engine?

        let screenSetViewController = NativeScreenSetsViewController()
        viewController.present(screenSetViewController, animated: true, completion: nil)
    }
}
