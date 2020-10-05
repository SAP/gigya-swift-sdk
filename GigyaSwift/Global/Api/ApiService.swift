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

final class ApiService: ApiServiceProtocol {

    let sessionService: SessionServiceProtocol?

    private let networkAdapter: NetworkAdapterProtocol?

    private let persistenceService: PersistenceService

    required init(with networkAdapter: NetworkAdapterProtocol, session: SessionServiceProtocol, persistenceService: PersistenceService) {
        self.networkAdapter = networkAdapter
        self.sessionService = session
        self.persistenceService = persistenceService
    }

    func getSDKConfig() {
        let params = ["include": "permissions,ids,appIds"]
        let model = ApiRequestModel(method: GigyaDefinitions.API.getSdkConfig, params: params)

        self.sendBlocking(model: model, responseType: InitSdkResponseModel.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.persistenceService.save(ids: data.ids)
                self?.persistenceService.isInitSdk = true
            case .failure(let error):
                GigyaLogger.log(with: self, message: error.localizedDescription)
                break
            }
        }
    }

    func send<T: Codable>(model: ApiRequestModel, responseType: T.Type,
                          completion: @escaping (GigyaApiResult<T>) -> Void) {
        if persistenceService.isInitSdk == false {
            getSDKConfig()
        }
        
        send(model: model, responseType: responseType, blocking: false, completion: completion)
    }

    func sendBlocking<T: Codable>(model: ApiRequestModel, responseType: T.Type,
                          completion: @escaping (GigyaApiResult<T>) -> Void) {
        send(model: model, responseType: responseType, blocking: true, completion: completion)
    }

    // Send request to server
    private func send<T: Codable>(model: ApiRequestModel, responseType: T.Type, blocking: Bool,
                          completion: @escaping (GigyaApiResult<T>) -> Void) {

        networkAdapter?.send(model: model, blocking: blocking) { [weak self] (data, error) in

            if error == nil {
                main { [weak self] in
                    self?.validateResult(tmpData: model, responseType: responseType, data: data, completion: completion)
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
    private func validateResult<T: Codable>(tmpData: ApiRequestModel? = nil, responseType: T.Type, data: NSData?,
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

            // retry when the error is request expired
            if isRetryNeeded(with: gigyaResponse.errorCode) {
                let retryDispacer = NetworkRetryDispacher<T>(networkAdapter: networkAdapter, tmpModel: tmpData!)
                retryDispacer.startRetry { [weak self] (data) in
                    self?.validateResult(responseType: T.self, data: data, completion: completion)
                }
                return
            }

            if gigyaResponse.errorCode == 0 {
                do {
                    let typedResponse = try DecodeEncodeUtils.decode(fromType: responseType.self, data: data as Data)

                    GigyaLogger.log(with: self, message: "[Response]: \(typedResponse)")

                    main { completion(GigyaApiResult.success(data: typedResponse)) }
                } catch let error {
                    GigyaLogger.log(with: self, message: error.localizedDescription)
                    main { completion(.failure(NetworkError.jsonParsingError(error: error))) }
                }

            } else {
                GigyaLogger.log(with: self, message: "Failed: \(gigyaResponse)")
                main { completion(.failure(.gigyaError(data: gigyaResponse))) }
            }

        } catch let error {
            GigyaLogger.log(with: self, message: error.localizedDescription)
            main { completion(.failure(NetworkError.jsonParsingError(error: error))) }
        }
    }

    private func isRetryNeeded(with errorCode: Int) -> Bool {
        return errorCode == GigyaDefinitions.ErrorCode.requestExpired
    }

    deinit {
//        self.tmpModel = nil
    }
}
