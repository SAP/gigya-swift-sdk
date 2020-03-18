//
//  SocialManagerTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import Gigya

class SocialManagerTests: XCTestCase {
    let ioc = GigyaContainerUtils.shared
    
    var socialManager: SocialProvidersManagerProtocol?
    var sessionService: SessionServiceProtocol?
    var config: GigyaConfig?
    var persistenceService: PersistenceService?
    var networkAdapter: NetworkAdapterProtocol?

    override func setUp() {
        sessionService = ioc.container.resolve(SessionServiceProtocol.self)!
        config = ioc.container.resolve(GigyaConfig.self)!
        persistenceService = ioc.container.resolve(PersistenceService.self)
        networkAdapter = ioc.container.resolve(NetworkAdapterProtocol.self)
    }

    func testGetGoogleProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!, persistenceService: persistenceService!, networkAdapter: self.networkAdapter!)
            let _ = self.socialManager?.getProvider(with: .google, delegate: self)
            XCTAssert(true)

        }
    }

    // check provider not extend to ProviderWrapperProtocol and check provider sdk not install
    func testGetProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!, persistenceService: persistenceService!, networkAdapter: self.networkAdapter!)

            self.expectFatalError(expectedMessage: "[facebook] can't login with WebView, install related sdk.") {
                let _ = self.socialManager?.getProvider(with: .facebook, delegate: self)
                XCTAssert(true)
            }
        }
    }

    func testGetWechatProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!, persistenceService: persistenceService!, networkAdapter: self.networkAdapter!)

            self.expectFatalError(expectedMessage: "[wechat] can't login with WebView, install related sdk.") {
                let _ = self.socialManager?.getProvider(with: .wechat, delegate: self)
                XCTAssert(true)
            }
        }
    }
    
}

extension SocialManagerTests: BusinessApiDelegate {

    func callSetAccount<T>(dataType: T.Type, params: [String : Any], completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {
        
    }

    func callSetAccount<T>(params: [String : Any], completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {
        
    }

    func callfinalizeRegistration<T>(regToken: String, completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {
        
    }

    func sendApi(api: String, params: [String: Any], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {

    }

    func sendApi<T>(dataType: T.Type, api: String, params: [String: Any], completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callNativeSocialLogin<T>(params: [String : Any], completion: @escaping (GigyaApiResult<T>?) -> Void) where T : Decodable, T : Encodable {

    }

    func callGetAccount<T>(completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callSociallogin<T>(provider: GigyaSocialProviders, viewController: UIViewController, params: [String : Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callLogin<T>(dataType: T.Type, loginId: String, password: String, params: [String : Any], completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {

    }


}
