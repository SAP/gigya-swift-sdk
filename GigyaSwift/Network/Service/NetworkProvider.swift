//
//  APIService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class NetworkProvider {

    weak var config: GigyaConfig?

    let persistenceService: PersistenceService

    var sessionService: SessionServiceProtocol

    let urlSession = URLSession.sharedInternal

    init(config: GigyaConfig, persistenceService: PersistenceService, sessionService: SessionServiceProtocol) {
        self.config = config
        self.persistenceService = persistenceService
        self.sessionService = sessionService
    }

    func unsignRequest(url: String, model: ApiRequestModel, method: NetworkMethod = .post, completion: @escaping GigyaResponseHandler) {

        doRequest(url: url, model: model, method: method, completion: completion, disableSign: true)
    }

    func dataRequest(model: ApiRequestModel, method: NetworkMethod = .post, completion: @escaping GigyaResponseHandler) {
        let url = makeUrl(with: model.method)

        doRequest(url: url, model: model, method: method, completion: completion)
    }

    private func doRequest(url: String, model: ApiRequestModel, method: NetworkMethod = .post, completion: @escaping GigyaResponseHandler, disableSign: Bool = false) {

        guard var dataURL = URL(string: url) else {
            DispatchQueue.main.async { completion(nil, NetworkError.createURLRequestFailed) }
            return
        }

        let urlAllowed = NSCharacterSet(charactersIn: GigyaDefinitions.charactersAllowed).inverted

        let newParams = model.params

        dataURL.appendPathComponent(model.method)

        var request: URLRequest = URLRequest(url: dataURL)
        request.timeoutInterval = TimeInterval(config?.requestTimeout ?? InternalConfig.Network.requestTimeoutDefult)

        // Encode body request to params
        do {
            let bodyData: [String : Any] = try SignatureUtils.prepareSignature(config: config!, persistenceService: persistenceService, session: disableSign ? nil : sessionService.session, path: model.method, params: newParams ?? [:])

            let bodyDataParmas = bodyData.mapValues { value -> String in
                return "\(value)"
            }

            let bodyString: String = bodyDataParmas.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }
            
            request.httpBody = bodyString.dropLast().data(using: .utf8)

            GigyaLogger.log(with: self, message: "[Request]:httpBody, jsonData: \(bodyString)")

        } catch {
            GigyaLogger.log(with: self, message: "Error: \(NetworkError.createURLRequestFailed.localizedDescription)")

            completion(nil, NetworkError.createURLRequestFailed)
            return
        }

        // Set the request method type
        request.httpMethod = method.description
        var task: URLSessionDataTask?

        let handler: (Data?, URLResponse?, Error?) -> Void = { [weak config] data, response, error in
            if let headerResponse = response as? HTTPURLResponse, let date = headerResponse.allHeaderFields["Date"] as? String {

                if let dateFromRequest = date.stringToDate() {
                    config?.timestampOffset = dateFromRequest.timeIntervalSince1970 - Date().timeIntervalSince1970
                }
            }

            guard error == nil else {
                completion(nil, NetworkError.networkError(error: error!))
                return
            }

            guard let data = data else {
                completion(nil, NetworkError.emptyResponse)
                return
            }

            // Decode json result to Struct
            completion(data as NSData, nil)
        }

        task = urlSession.dataTask(with: request, completionHandler: handler)
        task?.resume()
    }

    private func makeUrl(with path: String) -> String {
        let url = "https://\(path.split(separator: ".")[0]).\(self.config!.apiDomain)"
        return url
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }

}

