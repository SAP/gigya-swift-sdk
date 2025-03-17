//
//  CaptchaResolver.swift
//  GigyaSwift
//
//  Created by Sagi Shmuel on 11/03/2025.
//  Copyright © 2025 Gigya. All rights reserved.
//


import UIKit

final public class CaptchaResolver<T: GigyaAccountProtocol>: BaseResolver {
    
    let originalError: NetworkError

    let dataResponse: [String: Any]
    let model: ApiRequestModel?
    
    weak var businessDelegate: BusinessApiDelegate?

    let completion: (GigyaLoginResult<T>) -> Void
    
    init(originalError: NetworkError, businessDelegate: BusinessApiDelegate, dataResponse: [String: Any], completion: @escaping (GigyaLoginResult<T>) -> Void, model: ApiRequestModel? = nil) {
        self.completion = completion
        self.businessDelegate = businessDelegate
        self.dataResponse = dataResponse
        self.model = model
        self.originalError = originalError
    }

    internal func start() {
        let loginError = LoginApiError<T>(error: self.originalError, interruption: .captchaRequired(resolver: self))
        self.completion(.failure(loginError))

    }
    
    public func `continue`(params: [String: Any]) {
        let newParams = model!.params!
                        .merging(params) { (_, new) in new }

        businessDelegate?.sendApi(dataType: T.self, api: model?.method ?? "", params: newParams) { [weak self] result in
            switch result {
            case .success(let data):
                self?.completion(.success(data: data))
            case .failure(let error):
                let loginError = LoginApiError<T>(error: error, interruption: nil)
                self?.completion(.failure(loginError))
            }
        }
    }
    
}
