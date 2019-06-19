//
//  GigyaRequest.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaInfra

typealias GigyaResponse = GSResponse
public typealias GigyaDictionary = [String: AnyCodable]

class ApiService: IOCApiServiceProtocol {
    let networkAdapter: IOCNetworkAdapterProtocol?

    required init(with networkAdapter: IOCNetworkAdapterProtocol) {
        self.networkAdapter = networkAdapter
    }

    // Send request to server
    func send<T: Codable>(model: ApiRequestModel, responseType: T.Type,
                          completion: @escaping (GigyaApiResult<T>) -> Void) {
        
        self.networkAdapter?.send(model: model) { (data, error) in
            if error == nil {
                self.validateResult(responseType: responseType, data: data, completion: completion)
                return
            }

            GigyaLogger.log(with: self, message: "Error: \(String(describing: error?.localizedDescription))")
            let error = error as NSError?

            guard let code = error?.code, let callId = error?.userInfo["callId"] as? String else {
                return completion(.failure(NetworkError.networkError(error: error!)))
            }

            let errorModel = GigyaResponseModel(statusCode: .unknown, errorCode: code,
                                                      callId: callId,
                                                      errorMessage: error?.localizedDescription,
                                                      requestData: data as Data?)

            completion(.failure(NetworkError.gigyaError(data: errorModel)))
        }
    }

    // Validate and decode the result to GigyaApiResult
    private func validateResult<T: Codable>(responseType: T.Type, data: NSData?,
                                            completion: @escaping (GigyaApiResult<T>) -> Void) {
        guard let data = data else {
            GigyaLogger.log(with: self, message: "Error: data not found)")
            return completion(.failure(NetworkError.emptyResponse))
        }

        do {
            var gigyaResponse = try DecodeEncodeUtils.decode(fromType: GigyaResponseModel.self, data: data as Data)
            gigyaResponse.requestData = data as Data

            if gigyaResponse.errorCode == 0 {
                let typedResponse = try DecodeEncodeUtils.decode(fromType: responseType.self, data: data as Data)
                completion(GigyaApiResult.success(data: typedResponse))
            } else {    
                GigyaLogger.log(with: self, message: "Failed: \(gigyaResponse)")
                completion(.failure(.gigyaError(data: gigyaResponse)))
            }

        } catch let error {
            GigyaLogger.log(with: self, message: error.localizedDescription)
            completion(.failure(NetworkError.jsonParsingError(error: error)))
        }
    }
}
