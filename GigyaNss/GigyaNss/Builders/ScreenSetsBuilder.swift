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
    var dependenciesContainer = Gigya.getContainer()

    let engineLifeCycle: EngineLifeCycle

    var loadModel: ScreenLoadType?
    var screenName: String?
    var langName: String?

    var handlerExists: Bool?

    var eventsClosuresManager: EventsClosuresManager?

    init(engineLifeCycle: EngineLifeCycle) {
        self.engineLifeCycle = engineLifeCycle
    }

    @discardableResult
    func load(withAsset asset: String) -> BuilderOptions {
        loadModel = .asset(value: asset)

        registerInit()
        return self
    }

    @discardableResult
    func load(screenSetId id: String) -> BuilderOptions {
        loadModel = .id(value: id)

        registerInit()

        return self
    }

    private func registerInit() {
        handlerExists = false

        eventsClosuresManager = dependenciesContainer.resolve(EventsClosuresManager.self)
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

    func lang(name: String) -> BuilderOptions {
        langName = name
        return self
    }

    func events<B: GigyaAccountProtocol>(_ scheme: B.Type, handler: @escaping (NssEvents<B>) -> Void) -> BuilderOptions {
        dependenciesContainer.register(service: NssHandler<B>.self) { _ in
            return handler
        }
        handlerExists = true

        return self
    }

    func events(handler: @escaping (NssEvents<GigyaAccount>) -> Void) -> BuilderOptions {
        dependenciesContainer.register(service: NssHandler<GigyaAccount>.self) { _ in
            return handler
        }
        handlerExists = true

        return self
    }

    func eventsFor(screen: String, handler: @escaping (NssScreenEvent) -> Void) -> BuilderOptions {
        eventsClosuresManager?[screen] = handler
        return self
    }
}


// MARK: - Builder actions

extension ScreenSetsBuilder: ScreenSetsActionsBuilderProtocol {

    func show(viewController: UIViewController) {
        // TODO: How to check if the screenSetId is exists? Maybe need to check it in the flutter engine?
        guard let screenSetViewController = GigyaNss.shared.dependenciesContainer.resolve(NativeScreenSetsViewController<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "dependency not found, verify that you have implemented `GigyaNss.shared.register()`.")
        }

        // build the screen with the asset
        screenSetViewController.viewModel?.eventsClosuresManager = eventsClosuresManager
        screenSetViewController.build()
        screenSetViewController.presentationController?.delegate = screenSetViewController.viewModel

        eventsClosuresManager = nil
        
        guard dependenciesContainer.resolve((NssHandler<T>).self) != nil || handlerExists == false else {
            GigyaLogger.error(with: GigyaNss.self, message: "scheme is not same to the core scheme")
        }

        engineLifeCycle.register(asset: loadModel,
                                 initialRoute: screenName,
                                 defaultLang: langName,
                                 presentFrom: viewController,
                                 to: screenSetViewController
        )
    }
}

@frozen
public enum NssEvents<ResponseType: GigyaAccountProtocol> {
    case success(screenId: String, action: NssAction, data: ResponseType?)
    case error(screenId: String, error: NetworkError)
    case canceled
}
