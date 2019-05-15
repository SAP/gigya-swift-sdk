//
//  TFAResolver.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 15/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum TFAProvider: String {
    case gigyaPhone = "gigyaPhone"
    case email = "gigyaEmail"
    case totp = "gigyaTotp"
}

public class TFAResolver<T: Codable> : BaseResolver {
    
    let originalError: NetworkError
    
    let regToken: String
    
    weak var businessDelegate: BusinessApiDelegate?
    
    let completion: (GigyaLoginResult<T>) -> Void

    init(originalError: NetworkError, regToken: String, businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.originalError = originalError
        self.regToken = regToken
        self.completion = completion
        self.businessDelegate = businessDelegate
        
        getTFAProviders()
    }
    
    private func getTFAProviders() {
        let params = ["regToken": self.regToken]
        self.businessDelegate?.sendApi(dataType: ConflictingAccountHead.self, api: GigyaDefinitions.API.tfaGetProviders, params: params) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let data):
                
                break
            case .failure(_):
                break
            }
        }
    }
    

    
}
