//
//  GigyaIOCContainer.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 10/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol GigyaContainerProtocol {
    var container: IOCContainer { get set }
}

final class GigyaIOCContainer<T: GigyaAccountProtocol>: GigyaContainerProtocol {
    var container: IOCContainer

    init() {
        self.container = IOCContainer()

        registerDependencies()
    }

    private func registerDependencies() {
        container.register(service: GigyaConfig.self, isSingleton: true) { _ in GigyaConfig() }

        container.register(service: GeneralUtils.self) { resolver in
            return GeneralUtils()
        }

        container.register(service: UserNotificationCenterProtocol.self) { resolver in
            return UserNotificationCenterHelper()
        }

        container.register(service: SessionVerificationServiceProtocol.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let busnessApi = resolver.resolve(BusinessApiServiceProtocol.self)

            return SessionVerificationService(config: config!,
                                              apiService: apiService!,
                                              sessionService: sessionService!,
                                              businessApi: busnessApi!)
        }

        container.register(service: PushNotificationsServiceProtocol.self, isSingleton: true) { resolver in
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let generalUtils = resolver.resolve(GeneralUtils.self)
            let biometricService = resolver.resolve(BiometricServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let userNotificationCenter = resolver.resolve(UserNotificationCenterProtocol.self)

            return PushNotificationsService(apiService: apiService!,
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

        container.register(service: NetworkBlockingQueueUtils.self) { resolver in
            return NetworkBlockingQueueUtils()
        }

        container.register(service: NetworkProvider.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return NetworkProvider(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: NetworkAdapterProtocol.self, isSingleton: true) { resolver in
            let networkProvider = resolver.resolve(NetworkProvider.self)
            let queueUtils = resolver.resolve(NetworkBlockingQueueUtils.self)

            return NetworkAdapter(networkProvider: networkProvider!, queueHelper: queueUtils!)
        }

        container.register(service: ApiServiceProtocol.self) { resolver in
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let reportingService = resolver.resolve(ReportingService.self)

            return ApiService(with: resolver.resolve(NetworkAdapterProtocol.self)!, session: sessionService!, persistenceService: persistenceService!, reportingService: reportingService!)
        }

        container.register(service: KeychainStorageFactory.self) { resolver in
            let plistFactory = resolver.resolve(PlistConfigFactory.self)

            return KeychainStorageFactory(plistFactory: plistFactory!)
        }

        container.register(service: SessionServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let keychainHelper = resolver.resolve(KeychainStorageFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return SessionService(config: config!, persistenceService: persistenceService!, accountService: accountService!, keychainHelper: keychainHelper!)
        }

        container.register(service: BiometricServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return BiometricService(config: config!, persistenceService: persistenceService!, sessionService: sessionService!)
        }

        container.register(service: BiometricServiceInternalProtocol.self, isSingleton: true) { resolver in
            let biometric = resolver.resolve(BiometricServiceProtocol.self)

            return biometric as! BiometricServiceInternalProtocol
        }

        container.register(service: SocialProvidersManagerProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let networkAdapter = resolver.resolve(NetworkAdapterProtocol.self)

            return SocialProvidersManager(sessionService: sessionService!, config: config!, persistenceService: persistenceService!, networkAdapter: networkAdapter!)
        }

        container.register(service: ReportingService.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let networkProvider = resolver.resolve(NetworkProvider.self)

            return ReportingService(networkProvider: networkProvider!, config: config!)
        }

        container.register(service: BusinessApiServiceProtocol.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let apiService = resolver.resolve(ApiServiceProtocol.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)
            let providerFactory = resolver.resolve(SocialProvidersManagerProtocol.self)
            let interruptionsHandler = resolver.resolve(InterruptionResolverFactoryProtocol.self)
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

        container.register(service: AccountServiceProtocol.self, isSingleton: true) { _ in
            return AccountService()
        }

        container.register(service: PersistenceService.self, isSingleton: true) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            return PersistenceService(config: config)
        }

        container.register(service: InterruptionResolverFactoryProtocol.self) { _ in
            return InterruptionResolverFactory()
        }

        container.register(service: PlistConfigFactory.self) { _ in
            return PlistConfigFactory()
        }

        container.register(service: GigyaWebBridge<T>.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)
            let wbBridgeInterruptionManager = resolver.resolve(WebBridgeInterruptionResolverFactoryProtocol.self)

            return GigyaWebBridge(config: config!, persistenceService: persistenceService!, sessionService: sessionService!, businessApiService: businessService!, interruptionManager: wbBridgeInterruptionManager!)
        }
        
        container.register(service: WebBridgeInterruptionResolverFactoryProtocol.self) { resolver in
            let businessService = resolver.resolve(BusinessApiDelegate.self)
            let accountService = resolver.resolve(AccountServiceProtocol.self)

            return WebBridgeInterruptionManager(busnessApi: businessService!, accountService: accountService!)
        }

        container.register(service: GigyaCore<T>.self) { resolver in
            let config = resolver.resolve(GigyaConfig.self)
            let sessionService = resolver.resolve(SessionServiceProtocol.self)
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)
            let biometricService = resolver.resolve(BiometricServiceProtocol.self)
            let interruptionResolver = resolver.resolve(InterruptionResolverFactoryProtocol.self)
            let plistFactory = resolver.resolve(PlistConfigFactory.self)
            let persistenceService = resolver.resolve(PersistenceService.self)
            let container = resolver.resolve(IOCContainer.self)
            let sessionVerificationService = resolver.resolve(SessionVerificationServiceProtocol.self)
            let webAuthn = resolver.resolve(WebAuthnService<T>.self)

            return GigyaCore(config: config!,
                             persistenceService: persistenceService!,
                             businessApiService: businessService!,
                             sessionService: sessionService!,
                             interruptionResolver: interruptionResolver!,
                             biometric: biometricService!,
                             plistFactory: plistFactory!,
                             sessionVerificationService: sessionVerificationService!,
                             webAuthn: webAuthn!,
                             container: container!)
        }

        container.register(service: IOCContainer.self) { [weak self] _ in
            return self!.container
        }

        container.register(service: BusinessApiDelegate.self) { resolver in
            let businessService = resolver.resolve(BusinessApiServiceProtocol.self)

            return businessService as! BusinessApiDelegate
        }
        
        container.register(service: WebAuthnService<T>.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiServiceProtocol.self)
            let webAuthnDeviceIntegration = resolver.resolve(WebAuthnDeviceIntegration.self)
            let oauthService = resolver.resolve(OauthService.self)
            let attestationUtils = resolver.resolve(WebAuthnAttestationUtils.self)
            let persistenceService = resolver.resolve(PersistenceService.self)

            return WebAuthnService(businessApiService: busnessApi!, webAuthnDeviceIntegration: webAuthnDeviceIntegration!, oauthService: oauthService!, attestationUtils: attestationUtils!, persistenceService: persistenceService!)
        }
        
        container.register(service: WebAuthnAttestationUtils.self) { resolver in
            return WebAuthnAttestationUtils()
        }
        
        container.register(service: WebAuthnDeviceIntegration.self) { resolver in
            return WebAuthnDeviceIntegration()
        }
        
        container.register(service: OauthService.self) { resolver in
            let busnessApi = resolver.resolve(BusinessApiServiceProtocol.self)

            return OauthService(businessApiService: busnessApi!)
        }
    }
}
