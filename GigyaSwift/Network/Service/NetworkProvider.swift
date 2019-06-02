//
//  APIService.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import GigyaSDK

class NetworkProvider {
    let url: String

    let config: GigyaConfig

    init(url: String, config: GigyaConfig) {
        self.url = url
        self.config = config
    }

    func dataRequest(gsession: GigyaSession?,
                                    path: String, params: [String: String]?, method: NetworkMethod = .post, completion: @escaping GigyaResponseHandler) {
        let url = "https://\(path.split(separator: ".")[0]).\(self.url)"

        guard var dataURL = URL(string: url) else {
            DispatchQueue.main.async { completion(nil, NetworkError.createURLRequestFailed) }
            return
        }

        let urlAllowed = NSCharacterSet(charactersIn: "!*'();/:@&=+$,?%#[]{}\" ").inverted

        let newParams = params

        dataURL.appendPathComponent(path)

        let session = URLSession.shared
        var request: URLRequest = URLRequest(url: dataURL)

        // Encode body request to params
        do {
            let bodyData = try prepareSignature(session: gsession, path: path, params: newParams ?? [:]) as! [String: String]
            let bodyString: String = bodyData.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }

            request.httpBody = bodyString.dropLast().data(using: String.Encoding.utf8)

            print("[ApiService] httpBody, jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")

        } catch {
            completion(nil, NetworkError.createURLRequestFailed)
            return
        }

        // Set the request method type
        request.httpMethod = method.description

        let task = session.dataTask(with: request, completionHandler: { data, _, error in

            guard error == nil else {
                completion(nil, NetworkError.networkError(error!))
                return
            }

            guard let data = data else {
                completion(nil, NetworkError.dataNotFound)
                return
            }

            // Decode json result to Struct
            completion(data as NSData, nil)

        })

        task.resume()
    }

    private func prepareSignature(session: GigyaSession?, path: String, params: [String: String] = [:]) throws -> [String: Any] {
        let timestamp: Int = Int(Date().timeIntervalSince1970) + 0
        let nonce = String(timestamp) + "_" + String(describing: arc4random())

        let sigUtils = SignatureUtils()

        //swiftlint:disable:next line_length
        let signatureModel = GigyaRequestSignature(oauthToken: session?.token, apikey: config.apiKey!, nonce: nonce, timestamp: String(timestamp), ucid: config.ucid, gmid: config.gmid)

        let encoderPrepareData = try JSONEncoder().encode(signatureModel)
        let bodyPrepareData = try JSONSerialization.jsonObject(with: encoderPrepareData, options: .allowFragments) as! [String: String]

        var combinedData = params.merging(bodyPrepareData) { $1 }

        if let session = session {
            let sig = sigUtils.hmac(algorithm: .SHA1, url: sigUtils.oauth1SignatureBaseString(config.apiDomain ,path, combinedData), secret: session.secret)

            combinedData["sig"] = sig
        }

        return combinedData
    }
}
