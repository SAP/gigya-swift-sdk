////
////  LineWrapper.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 02/05/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//import LineSDK
//
//class LineWrapper: NSObject, ProviderWrapperProtocol {
//
//    var clientID: String? = {
//        let config = (Bundle.main.infoDictionary?["LineSDKConfig"] as? [String: String])
//        return config?["ChannelID"]
//    }()
//
//    lazy var line: LineSDKLogin = {
//        return LineSDKLogin.sharedInstance()
//    }()
//
//    private var completionHandler: (_ token: String?, _ secret: String?, _ error: String?) -> Void = { _, _, _  in }
//
//    override init() {
//        super.init()
//
//        line.delegate = self
//    }
//
//    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
//               completion: @escaping (_ token: String?, _ secret: String?, _ error: String?) -> Void) {
//        completionHandler = completion
//
//        line.start()
//    }
//
//    func logout() {
//        let apiClient = LineSDKAPI.init(configuration: LineSDKConfiguration.defaultConfig())
//        apiClient.logout(queue: .main) { (_, _) in }
//    }
//
//    deinit {
//        print("[LineWrapper deinit]")
//    }
//}
//
//extension LineWrapper: LineSDKLoginDelegate {
//    func didLogin(_ login: LineSDKLogin, credential: LineSDKCredential?, profile: LineSDKProfile?, error: Error?) {
//        guard error == nil else {
//            completionHandler(nil, nil, error?.localizedDescription)
//            return
//        }
//        completionHandler(credential?.accessToken?.accessToken, nil, nil)
//    }
//}
