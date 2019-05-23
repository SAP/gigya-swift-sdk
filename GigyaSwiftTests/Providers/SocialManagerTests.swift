//
//  SocialManagerTests.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 20/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import XCTest
@testable import GigyaSwift

class SocialManagerTests: XCTestCase {
    let ioc = GigyaContainerUtils()
    
    var socialManager: IOCSocialProvidersManagerProtocol?
    var sessionService: IOCSessionServiceProtocol?
    var config: GigyaConfig?

    override func setUp() {
        sessionService = ioc.container.resolve(IOCSessionServiceProtocol.self)!
        config = ioc.container.resolve(GigyaConfig.self)!

    }

    func testGetGoogleProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!)
            let _ = self.socialManager?.getProvider(with: .google, delegate: self)
            XCTAssert(true)

        }
    }

    // check provider not extend to ProviderWrapperProtocol and check provider sdk not install
    func testGetProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!)

            self.expectFatalError(expectedMessage: "[facebook] can't login with WebView, install related sdk.") {
                let _ = self.socialManager?.getProvider(with: .facebook, delegate: self)
                XCTAssert(true)
            }
        }
    }

    func testGetWechatProvider() {
        do {
            self.socialManager = SocialProvidersManager(sessionService: self.sessionService!, config: self.config!)

            self.expectFatalError(expectedMessage: "[wechat] can't login with WebView, install related sdk.") {
                let _ = self.socialManager?.getProvider(with: .wechat, delegate: self)
                XCTAssert(true)
            }
        }
    }
    
}

extension SocialManagerTests: BusinessApiDelegate {
    func callfinalizeRegistration<T>(regToken: String, completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {
        
    }

    func sendApi(api: String, params: [String : String], completion: @escaping (GigyaApiResult<GigyaDictionary>) -> Void) {

    }

    func sendApi<T>(dataType: T.Type, api: String, params: [String : String], completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callNativeSocialLogin<T>(params: [String : Any], completion: @escaping (GigyaApiResult<T>?) -> Void) where T : Decodable, T : Encodable {

    }

    func callGetAccount<T>(completion: @escaping (GigyaApiResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callSociallogin<T>(provider: GigyaSocielProviders, viewController: UIViewController, params: [String : Any], dataType: T.Type, completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {

    }

    func callLogin<T>(dataType: T.Type, loginId: String, password: String, params: [String : Any], completion: @escaping (GigyaLoginResult<T>) -> Void) where T : Decodable, T : Encodable {

    }


}
