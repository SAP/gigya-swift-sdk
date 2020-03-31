//
//  GigyaNss.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 08/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Flutter
import Gigya

final public class GigyaNss {
    public static var shared = GigyaNss()

    var dependenciesContainer = Gigya.getContainer()

    // Channels id's
    static var ignitionChannel = "gigya_nss_engine/method/ignition"
    static var screenChannel = "gigya_nss_engine/method/screen"
    static var apiChannel = "gigya_nss_engine/method/api"
    static var logChannel = "gigya_nss_engine/method/log"

    // Engine configuration
    static let engineBundle = "Gigya.GigyaNssEngine"
    static let engineId = "io.flutter"

    var builder: ScreenSetsMainBuilderProtocol?

    /**
    Show ScreenSet

    - Parameter name:           ScreenSet name.
    - Parameter viewController: Shown view controller.
    */

//    public func showScreenSet(with name: String, viewController: UIViewController) {
//        let screenSetViewController = NativeScreenSetsViewController()
//        let nav = UINavigationController(rootViewController: screenSetViewController)
//
//        viewController.present(nav, animated: true, completion: nil)
//    }

    @discardableResult
    public func load(asset: String) -> BuilderOptions {
        return builder!.load(withAsset: asset)
    }

    public func register<T: GigyaAccountProtocol>(scheme: T.Type) {

        dependenciesContainer.register(service: NssFlowManager<T>.self) { resolver in
            let flowFactory = resolver.resolve(ActionFactory<T>.self)

            return NssFlowManager(flowFactory: flowFactory!)
        }

        dependenciesContainer.register(service: ScreenSetsBuilder<T>.self) { resolver in
            let engineLifeCycle = resolver.resolve(EngineLifeCycle.self)!

            return ScreenSetsBuilder(engineLifeCycle: engineLifeCycle)
        }

        dependenciesContainer.register(service: NativeScreenSetsViewModel<T>.self) { resolver in
            let mainChannel = resolver.resolve(ScreenChannel.self)
            let apiChannel = resolver.resolve(ApiChannel.self)
            let logChannel = resolver.resolve(LogChannel.self)
            let flowManager = resolver.resolve(NssFlowManager<T>.self)

            return NativeScreenSetsViewModel(mainChannel: mainChannel!,
                                             apiChannel: apiChannel!,
                                             logChannel: logChannel!,
                                             flowManager: flowManager!
            )
        }

        dependenciesContainer.register(service: NativeScreenSetsViewController<T>.self) { resolver in
            let viewModel = resolver.resolve(NativeScreenSetsViewModel<T>.self)
            let createEngineFactory = resolver.resolve(CreateEngineFactory.self)

            return NativeScreenSetsViewController(viewModel: viewModel!, createEngineFactory: createEngineFactory!)
        }

        dependenciesContainer.register(service: EngineLifeCycle.self) { resolver in
            let ignitionChannel = resolver.resolve(IgnitionChannel.self)!
            let loaderHelper = resolver.resolve(LoaderFileHelper.self)!

            return EngineLifeCycle(ignitionChannel: ignitionChannel, loaderHelper: loaderHelper)
        }

        dependenciesContainer.register(service: LoaderFileHelper.self) { _ in
            return LoaderFileHelper()
        }

        dependenciesContainer.register(service: ScreenChannel.self) {  _ in
            return ScreenChannel()
        }

        dependenciesContainer.register(service: IgnitionChannel.self) {  _ in
            return IgnitionChannel()
        }

        dependenciesContainer.register(service: ApiChannel.self) {  _ in
            return ApiChannel()
        }

        dependenciesContainer.register(service: LogChannel.self) {  _ in
              return LogChannel()
        }

        dependenciesContainer.register(service: ActionFactory<T>.self) { _ in
            return ActionFactory()
        }

        dependenciesContainer.register(service: RegisterAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)
            
            return RegisterAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: LoginAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return LoginAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: SetAccountAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return SetAccountAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: CreateEngineFactory.self) { _ in
            return CreateEngineFactory()
        }

        guard let builder = GigyaNss.shared.dependenciesContainer.resolve(ScreenSetsBuilder<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "`ScreenSetsBuilder` dependency not found.")
        }

        self.builder = builder
    }
}
