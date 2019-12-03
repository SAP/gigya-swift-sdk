//
//  GigyaAppContextMock.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 28/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
@testable import Gigya

class GigyaContainerUtils {
    static let shared = GigyaContainerUtils()

    let container: IOCContainer = IOCContainer()

    init() {
        registerDependencie(GigyaAccount.self)
    }

    func registerDependencie<T: GigyaAccountProtocol>(_ type: T.Type) {
        container.register(service: GigyaConfig.self, isSingleton: true) { _ in GigyaConfig() }

        container.register(service: GeneralUtils.self, isSingleton: true) { resolver in
            return GeneralUtilsMock()
        }

        container.register(service: UserNotificationCenterProtocol.self, isSingleton: true) { resolver in
            return UserNotificationCenterMock()
        }

        container.register(service: PushNotificationsServiceProtocol.self) { resolver in
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let generalUtils = resolver.resolve(GeneralUtils.self)
            let biometricService = resolver.resolve(BiometricServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let userNotificationCenter = resolver.resolve(UserNotificationCenterProtocol.self)

            return PushNotificationsServiceMock(apiService: apiService!,
                                            sessionService: sessionService!,
                                            biometricService: biometricService!,
                                            generalUtils: generalUtils!,
                                            persistenceService: persistenceService!,
                                            userNotificationCenter: userNotificationCenter!
            )
        }

        container.register(service: PushNotificationsServiceExternalProtocol.self) { resolver in
            return resolver.resolve(PushNotificationsServiceProtocol.self) as! PushNotificationsServiceExternalProtocol

        }
        
        container.register(service: NetworkProvider.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return NetworkProvider(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: NetworkBlockingQueueUtils.self) { resolver in
            return NetworkBlockingQueueUtils()
        }

        container.register(service: NetworkAdapterProtocol.self) { resolver in
            let queueUtils = resolver.resolve(NetworkBlockingQueueUtils.self)
            let networkProvider = resolver.resolve(NetworkProvider.self)

            return NetworkAdapterMock(networkProvider: networkProvider!, queueHelper: queueUtils!)
        }

        container.register(service: InterruptionResolverFactoryProtocol.self) { _ in
            return InterruptionResolverFactory()
        }
        
        container.register(service: SocialProvidersManagerProtocol.self) { resolver in
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            return ProviderFactoryMock(sessionService: sessionService!, config: resolver.resolve(GigyaConfig.self)!)
        }

        container.register(service: ApiServiceProtocol.self) { resolver in
            let sessionService = resolver.resolve(SessionServiceProtocol.self)

            return ApiService(with: resolver.resolve(NetworkAdapterProtocol.self)!, session: sessionService!)
        }

        container.register(service: KeychainStorageFactory.self) { resolver in
            let plistFactory = resolver.resolve(PlistConfigFactory.self)

            return KeychainMock(plistFactory: plistFactory!)
        }

        container.register(service: SessionServiceProtocol.self, isSingleton: true) { resolver in
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let config = resolver.resolve(GigyaConfig.self)
            let keychainHelper = resolver.resolve(KeychainStorageFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return GigyaSessionServiceMock(config: config!, persistenceService: persistenceService!, accountService: accountService!, keychainHelper: keychainHelper!)
        }
        
        container.register(service: BiometricServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return BiometricService(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: BiometricServiceMock.self, isSingleton: true) { resolver in

            return BiometricServiceMock()
        }

        container.register(service: BiometricServiceInternalProtocol.self, isSingleton: true) { resolver in
            let biometric = resolver.resolve(BiometricServiceProtocol.self)

            return biometric as! BiometricServiceInternalProtocol
        }

        container.register(service: BusinessApiServiceProtocol.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let providerFactory = resolver.resolve(SocialProvidersManagerProtocol.self)
            let interruptionsHandler = resolver.resolve(InterruptionResolverFactory.self)
            let biometricService = resolver.resolve(BiometricServiceInternalProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return BusinessApiService(config: config!,
                                      persistenceService: persistenceService!,
                                      apiService: apiService!,
                                        sessionService: sessionService!,
                                        accountService: accountService!,
                                        providerFactory: providerFactory!,
                                        interruptionsHandler: interruptionsHandler!,
                                        biometricService: biometricService!)
        }

        container.register(service: AccountServiceProtocol.self, isSingleton: true) { _ in AccountService() }

        container.register(service: InterruptionResolverFactory.self) { _ in
            return InterruptionResolverFactory()
        }

        container.register(service: PersistenceService.self, isSingleton: true) { _ in
            return PersistenceService()
        }
        
        container.register(service: PlistConfigFactory.self) { _ in
            return PlistConfigFactory()
        }

        container.register(service: GigyaCore<T>.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)
            let biometricService = resolver.resolve(BiometricServiceProtocol.self)
            let interruptionResolver = resolver.resolve(InterruptionResolverFactory.self)
            let plistFactory = resolver.resolve(PlistConfigFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let container = resolver.resolve(IOCContainer.self)

            return GigyaCore(config: config!,
                             persistenceService: persistenceService!,
                             businessApiService: businessService!,
                             sessionService: sessionService!,
                             interruptionResolver: interruptionResolver!,
                             biometric: biometricService!,
                             plistFactory: plistFactory!, container: container!)
        }

        container.register(service: GigyaWebBridge<T>.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)

            return GigyaWebBridge(config: config!, persistenceService: persistenceService!, sessionService: sessionService!, businessApiService: businessService!)
        }

        container.register(service: IOCContainer.self) { [weak self] _ in
            return self!.container
        }
    }

}
