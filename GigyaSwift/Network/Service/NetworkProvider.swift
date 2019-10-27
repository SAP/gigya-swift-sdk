//
//  APIService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class NetworkProvider {
    let url: String

    let config: GigyaConfig

    let persistenceService: PersistenceService

    init(url: String, config: GigyaConfig, persistenceService: PersistenceService) {
        self.url = url
        self.config = config
        self.persistenceService = persistenceService
    }

    func dataRequest(gsession: GigyaSession?,
                                    path: String, params: [String: Any]?, method: NetworkMethod = .post, completion: @escaping GigyaResponseHandler) {
        let url = makeUrl(with: path)

        guard var dataURL = URL(string: url) else {
            DispatchQueue.main.async { completion(nil, NetworkError.createURLRequestFailed) }
            return
        }

        let urlAllowed = NSCharacterSet(charactersIn: "!*'();/:@&=+$,?%#[]{}\" ").inverted

        let newParams = params

        dataURL.appendPathComponent(path)

        let session = URLSession.sharedInternal

        var request: URLRequest = URLRequest(url: dataURL)

        // Encode body request to params
        do {
            let bodyData = try SignatureUtils.prepareSignature(config: config, persistenceService: persistenceService, session: gsession, path: path, params: newParams ?? [:])
            let bodyDataParmas = bodyData.mapValues { value -> String in
                return "\(value)"
            }

            let bodyString: String = bodyDataParmas.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }

            request.httpBody = bodyString.dropLast().data(using: String.Encoding.utf8)

            GigyaLogger.log(with: self, message: "[Request]:httpBody, jsonData: \(bodyDataParmas)")

        } catch {
            GigyaLogger.log(with: self, message: "Error: \(NetworkError.createURLRequestFailed.localizedDescription)")

            completion(nil, NetworkError.createURLRequestFailed)
            return
        }

        // Set the request method type
        request.httpMethod = method.description

        let task = session.dataTask(with: request, completionHandler: { data, _, error in

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

        })

        task.resume()
    }

    private func makeUrl(with path: String) -> String {
        let url = "https://\(path.split(separator: ".")[0]).\(self.url)"
        return url
    }
}
