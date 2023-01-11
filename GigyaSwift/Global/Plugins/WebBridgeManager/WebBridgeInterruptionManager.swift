//
//  WebBridgeInterruptionManager.swift
//  Gigya
//
//  Created by Sagi Shmuel on 01/08/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import Foundation

enum WebBridgeInterruption: Int {
    case forceLink = 409003
}

protocol WebBridgeInterruptionResolverFactoryProtocol {
    func interruptionHandler(error: NetworkError)
    
    func responseManager<T: GigyaAccountProtocol>(apiMethod: String, params: [String: String], data: T, completion: @escaping (GigyaPluginEvent<T>) -> Void)
}

class WebBridgeInterruptionManager: WebBridgeInterruptionResolverFactoryProtocol {
    private let busnessApi: BusinessApiDelegate

    private var resolver: WebBridgeResolver?
    
    private lazy var disposeResolver: () -> Void = { [weak self] in
        guard let self = self else { return }
        
        if self.resolver != nil {
            self.resolver = nil
        }
    }
    
    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }
    
    func responseManager<T: GigyaAccountProtocol>(apiMethod: String, params: [String: String], data: T, completion: @escaping (GigyaPluginEvent<T>) -> Void) {
        guard let resolver = resolver else {
            completion(.onLogin(account: data))
            return
        }
        
        resolver.resolve(apiMethod: apiMethod, params: params, data: data, completion: completion)
    }
    
    func interruptionHandler(error: NetworkError) {
        switch error {
        case .gigyaError(let data):
            let errorType = WebBridgeInterruption(rawValue: data.errorCode)
            
            switch errorType {
            case .forceLink:
                resolver = WebBridgeFroceLoginResolver(busnessApi: busnessApi, dispose: disposeResolver)
            default:
                break
            }
        default:
            break;
        }
    }
}
