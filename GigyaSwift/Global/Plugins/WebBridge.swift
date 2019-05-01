//
//  WebBridge.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK
import WebKit

protocol IOCWebBridgeProtocol {
    
    init(config: GigyaConfig)
    
    func onJSMessage(message: WKScriptMessage)
}


class WebBridge: IOCWebBridgeProtocol {
    
    var config: GigyaConfig
    
    required init(config: GigyaConfig) {
        self.config = config
    }
    
    // MARK: - JS Interfacing
    
    func onJSMessage(message: WKScriptMessage) {
        let action = message.body as? String
        print("Receieved JS injections withj action: \(action)")
        switch action {
        case "get_ids":
            break
        default:
            return
        }
    }
    
    func invokeCallback() {
        
    }
    
    // MARK: - Action handling
    
    
    
}
