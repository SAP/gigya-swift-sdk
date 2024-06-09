//
//  WebBridgeFroceLoginResolver.swift
//  Gigya
//
//  Created by Sagi Shmuel on 01/08/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import Foundation

protocol WebBridgeResolver: BaseResolver {
    init(busnessApi: BusinessApiDelegate, dispose: @escaping () -> Void)
    
    func resolve<T: GigyaAccountProtocol>(apiMethod: String, params: [String: String], data: T, completion: @escaping (GigyaPluginEvent<T>) -> Void)
}

class WebBridgeFroceLoginResolver: WebBridgeResolver {
    let dispose: () -> Void
    
    private let busnessApi: BusinessApiDelegate
    
    required init(busnessApi: BusinessApiDelegate, dispose: @escaping () -> Void) {
        self.dispose = dispose
        self.busnessApi = busnessApi
    }
    
    func resolve<T: GigyaAccountProtocol>(apiMethod: String, params: [String: String], data: T, completion: @escaping (GigyaPluginEvent<T>) -> Void) {
        if params["loginMode"] == "connect" || apiMethod == GigyaDefinitions.API.finalizeRegistration {
            busnessApi.callGetAccount(dataType: T.self, params: [:], clearAccount: true) { [weak self] result in
                switch result {
                case .success(data: let userdata):
                    completion(.onLogin(account: userdata))
                    completion(.onHide(event: ["isFlowFinalized": "true"]))
                case .failure(_):
                    break
                }
                
                self?.dispose()
            }
        
        }
    }
}
