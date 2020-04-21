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

    var handler: BuilderEventHandler<T>?

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

    func initialRoute(name: String) -> BuilderOptions {
        screenName = name
        return self
    }

    func events<B: GigyaAccountProtocol>(_ obj: B.Type, closure: @escaping (NssEvents<B>) -> Void) -> BuilderOptions {
//        self.handler = BuilderEventHandler(handler: closure)
        return self
    }
}

// MARK: - Builder actions

extension ScreenSetsBuilder: ScreenSetsActionsBuilderProtocol {
    func show(viewController: UIViewController) {
        
        // TODO: How to check if the screenSetId is exists? Maybe need to check it in the flutter engine?
        guard let screenSetViewController = GigyaNss.shared.dependenciesContainer.resolve(NativeScreenSetsViewController<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "`NativeScreenSetsViewController` dependency not found.")
        }

        // build the screen with the asset
        screenSetViewController.build()
        screenSetViewController.presentationController?.delegate = screenSetViewController.viewModel

        engineLifeCycle.register(asset: assetName,
                                 initialRoute: screenName,
                                 presentFrom: viewController,
                                 to: screenSetViewController
        )

    }
}

class BuilderEventHandler<T: GigyaAccountProtocol> {
    var handler: (NssEvents<T>) -> Void = { _ in }

    init(handler: @escaping (NssEvents<T>) -> Void) {
        self.handler = handler
    }
}

@frozen
public enum NssEvents<ResponseType: GigyaAccountProtocol> {
    case logged
    case error
    case canceled
}
