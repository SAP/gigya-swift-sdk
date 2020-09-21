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
    var dependenciesDidRegisterd = false

    // Channels id's
    static var ignitionChannel = "gigya_nss_engine/method/ignition"
    static var screenChannel = "gigya_nss_engine/method/screen"
    static var apiChannel = "gigya_nss_engine/method/api"
    static var logChannel = "gigya_nss_engine/method/log"
    static var dataChannel = "gigya_nss_engine/method/data"
    static var eventsChannel = "gigya_nss_engine/method/events"

    // Engine configuration
    static let engineBundle = "Gigya.GigyaNssEngine"
    static let engineId = "io.flutter"

    // extends files prefix
    static let themePrefix = "theme"
    static let langPrefix = "i18n"


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
        self.registerDependenciesIfNeeded()
        
        return builder!.load(withAsset: asset)
    }

    public func register<T: GigyaAccountProtocol>(scheme: T.Type) {
        dependenciesContainer.register(service: FlowManager<T>.self) { resolver in
            let flowFactory = resolver.resolve(ActionFactory<T>.self)
            let eventHandler = resolver.resolve(NssHandler<T>.self)

            return FlowManager(flowFactory: flowFactory!, eventHandler: eventHandler)
        }

        dependenciesContainer.register(service: ScreenSetsBuilder<T>.self) { resolver in
            let engineLifeCycle = resolver.resolve(EngineLifeCycle.self)!

            return ScreenSetsBuilder(engineLifeCycle: engineLifeCycle)
        }

        dependenciesContainer.register(service: NativeScreenSetsViewModel<T>.self) { resolver in
            let mainChannel = resolver.resolve(ScreenChannel.self)
            let apiChannel = resolver.resolve(ApiChannel.self)
            let logChannel = resolver.resolve(LogChannel.self)
            let dataChannel = resolver.resolve(DataChannel.self)
            let screenEventsChannel = resolver.resolve(EventsChannel.self)
            let dataResolver = resolver.resolve(DataResolver.self)
            let flowManager = resolver.resolve(FlowManager<T>.self)
            let eventHandler = resolver.resolve(NssHandler<T>.self)
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return NativeScreenSetsViewModel(mainChannel: mainChannel!,
                                             apiChannel: apiChannel!,
                                             logChannel: logChannel!,
                                             dataChannel: dataChannel!,
                                             screenEventsChannel: screenEventsChannel!,
                                             dataResolver: dataResolver!,
                                             busnessApi: busnessApi!,
                                             flowManager: flowManager!,
                                             eventHandler: eventHandler
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
            let schemaHelper = resolver.resolve(SchemaHelper.self)!

            return EngineLifeCycle(ignitionChannel: ignitionChannel, loaderHelper: loaderHelper, schemaHelper: schemaHelper)
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

        dependenciesContainer.register(service: DataChannel.self) {  _ in
              return DataChannel()
        }

        dependenciesContainer.register(service: EventsChannel.self) { _ in
            return EventsChannel()
        }

        dependenciesContainer.register(service: DataResolver.self) { _ in
            return DataResolver()
        }

        dependenciesContainer.register(service: ActionFactory<T>.self) { _ in
            return ActionFactory()
        }


        dependenciesContainer.register(service: RegisterAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)
            
            return RegisterAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: SchemaHelper.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return SchemaHelper(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: LoginAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return LoginAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: SetAccountAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return SetAccountAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: ForgotPasswordAction<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiDelegate.self)

            return ForgotPasswordAction(busnessApi: busnessApi!)
        }

        dependenciesContainer.register(service: CreateEngineFactory.self) { _ in
            return CreateEngineFactory()
        }

        dependenciesContainer.register(service: EventsClosuresManager.self) { _ in
            return EventsClosuresManager()
        }

        guard let builder = GigyaNss.shared.dependenciesContainer.resolve(ScreenSetsBuilder<T>.self) else {
            GigyaLogger.error(with: GigyaNss.self, message: "`ScreenSetsBuilder` dependency not found.")
        }
        self.builder = builder

        self.dependenciesDidRegisterd = true
    }

    private func registerDependenciesIfNeeded() {
        if !dependenciesDidRegisterd {
            register(scheme: GigyaAccount.self)
        }
    }
}
