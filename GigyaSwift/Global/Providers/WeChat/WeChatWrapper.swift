////
////  WeChatWrapper.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 02/05/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import UIKit
//import GigyaSDK
//
//class WeChatWrapper: NSObject, ProviderWrapperProtocol {
//
//    var clientID: String? = {
//        let config = (Bundle.main.infoDictionary?["LineSDKConfig"] as? [String: String])
//        return config?["ChannelID"]
//    }()
//
//    private var completionHandler: (_ token: String?, _ secret: String?, _ error: String?) -> Void = { _, _, _  in }
//
//    override init() {
//        super.init()
//
//    }
//
//    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
//               completion: @escaping (_ token: String?, _ secret: String?, _ error: String?) -> Void) {
//        completionHandler = completion
////        print(WXApi.isWXAppInstalled())
//    }
//
//    func logout() {
//
//    }
//
//    deinit {
//        print("[LineWrapper deinit]")
//    }
//}
