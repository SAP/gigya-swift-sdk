//
//  TFARegistrationResolver.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public protocol TFARegistrationResolverProtocol {
    
    func startRegistrationWithPhone(phoneNumber: String, method: String?)
    
    func verifyCode(provider: TFAProvider, authenticationCode: String)
}

public class TFARegistrationResolver<T: Codable> : TFAResolver<T>, TFARegistrationResolverProtocol {
    
    override init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        super.init(originalError: originalError, regToken: regToken, businessDelegate: businessDelegate, completion: completion)
    }
    
    public func startRegistrationWithPhone(phoneNumber: String, method: String?) {
        
    }
    
    public func verifyCode(provider: TFAProvider, authenticationCode: String) {
        
    }
    
}
