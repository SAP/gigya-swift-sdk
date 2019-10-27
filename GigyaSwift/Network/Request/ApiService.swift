//
//  GigyaRequest.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

//typealias GigyaResponse = GSResponse
public typealias GigyaDictionary = [String: AnyCodable]

class ApiService: ApiServiceProtocol {
    let networkAdapter: NetworkAdapterProtocol?

    let sessionService: SessionServiceProtocol?

    required init(with networkAdapter: NetworkAdapterProtocol, session: SessionServiceProtocol) {
        self.networkAdapter = networkAdapter
        self.sessionService = session
    }

    // Send request to server
    func send<T: Codable>(model: ApiRequestModel, responseType: T.Type,
                          completion: @escaping (GigyaApiResult<T>) -> Void) {
        self.networkAdapter?.send(model: model) { (data, error) in
            if error == nil {
                main { [weak self] in
                    self?.validateResult(responseType: responseType, data: data, completion: completion)
                }
                return
            }

            GigyaLogger.log(with: self, message: "Error: \(String(describing: error?.localizedDescription))")
            let error = error as NSError?

            guard let code = error?.code, let callId = error?.userInfo["callId"] as? String else {
                main { completion(.failure(NetworkError.networkError(error: error!))) }
                return
            }

            let errorModel = GigyaResponseModel(statusCode: .unknown, errorCode: code,
                                                      callId: callId,
                                                      errorMessage: error?.localizedDescription,
                                                      sessionInfo: nil,
                                                      requestData: data as Data?)

            completion(.failure(NetworkError.gigyaError(data: errorModel)))
        }
    }

    // Validate and decode the result to GigyaApiResult
    private func validateResult<T: Codable>(responseType: T.Type, data: NSData?,
                                            completion: @escaping (GigyaApiResult<T>) -> Void) {
        guard let data = data else {
            GigyaLogger.log(with: self, message: "Error: data not found)")
            main { completion(.failure(NetworkError.emptyResponse)) }
            return
        }

        do {
            var gigyaResponse = try DecodeEncodeUtils.decode(fromType: GigyaResponseModel.self, data: data as Data)
            gigyaResponse.requestData = data as Data

            sessionService?.setSession(gigyaResponse.sessionInfo)

            if gigyaResponse.errorCode == 0 {
                let typedResponse = try DecodeEncodeUtils.decode(fromType: responseType.self, data: data as Data)

                GigyaLogger.log(with: self, message: "[Response]: \(typedResponse)")

                main { completion(GigyaApiResult.success(data: typedResponse)) }
            } else {    
                GigyaLogger.log(with: self, message: "Failed: \(gigyaResponse)")
                main { completion(.failure(.gigyaError(data: gigyaResponse))) }
            }

        } catch let error {
            GigyaLogger.log(with: self, message: error.localizedDescription)
            main { completion(.failure(NetworkError.jsonParsingError(error: error))) }
        }
    }
}
