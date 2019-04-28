////
////  APIService.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 04/03/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
//import Foundation
//import GigyaSDK
//
//class NetworkProvider {
//    let url: String
//
//    init(url: String) {
//        self.url = url
//    }
//
//    func dataRequest<Body: Codable, Response: Codable>(gsession: GSSession,
//      path: String, body: Body, responseType: Response.Type, method: NetworkMethod = .post, completion: @escaping (NetworkResult<Response>) -> Void) {
//        let url = "https://\(path.split(separator: ".")[0]).\(self.url)"
//        guard var dataURL = URL(string: url) else {
//            DispatchQueue.main.async { completion(NetworkResult.failure(NetworkError.createURLRequestFailed)) }
//            return
//        }
//
//        dataURL.appendPathComponent(path)
//
//        let session = URLSession.shared
//        var request: URLRequest = URLRequest(url: dataURL)
//        let urlAllowed = NSCharacterSet(charactersIn: "!*'();/:@&=+$,?%#[]{}\" ").inverted
//
//        // Encode body request to params
//        do {
//
//            //swiftlint:disable:next force_cast
//            let bodyData = try prepareSignature(session: gsession, path: path, body: body) as! [String: String]
//            let bodyString: String = bodyData.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }
//
//            request.httpBody = bodyString.dropLast().data(using: String.Encoding.utf8)
//
//            print("[ApiService] httpBody, jsonData: ", String(data: request.httpBody!, encoding: .utf8) ?? "no body data")
//
//        } catch {
//            completion(NetworkResult.failure(NetworkError.createURLRequestFailed))
//            return
//        }
//
//        // Set the request method type
//        request.httpMethod = method.description
//
//        let task = session.dataTask(with: request, completionHandler: { data, _, error in
//
//            guard error == nil else {
//                completion(NetworkResult.failure(NetworkError.networkError(error!)))
//                return
//            }
//
//            guard let data = data else {
//                completion(NetworkResult.failure(NetworkError.dataNotFound))
//                return
//            }
//
//            // Decode json result to Struct
//            do {
//                let decodedObject = try JSONDecoder().decode(responseType.self, from: data)
//
//                completion(NetworkResult.success(decodedObject))
//            } catch let error {
//                // Parsing error, check your Struct
//                completion(NetworkResult.failure(NetworkError.jsonParsingError(error)))
//            }
//        })
//
//        task.resume()
//    }
//
//    private func prepareSignature<Body: Codable>(session: GSSession, path: String, body: Body) throws -> [String: Any] {
//        let timestamp: Int = Int(Date().timeIntervalSince1970) + 0
//        let nonce = String(timestamp) + "_" + String(describing: arc4random())
//
//        let sigUtils = SignatureUtils()
//
//        //swiftlint:disable:next line_length
//        let signatureModel = GigyaRequestSignature(oauthToken: session.token, apikey: "", nonce: nonce, timestamp: String(timestamp), ucid: "iyrFXHFzHMLUL97/YDimSQ==", gmid: "RSZiPg/1J8AxSits1VENBXRXCKKj4DrOrI2oOXqiUz0=")
//
//        let encoderPrepareData = try JSONEncoder().encode(signatureModel)
//        //swiftlint:disable:next force_cast
//        let bodyPrepareData = try JSONSerialization.jsonObject(with: encoderPrepareData, options: .allowFragments) as! [String: Any]
//
//        let encoderBodyData = try JSONEncoder().encode(body)
//        //swiftlint:disable:next force_cast
//        let bodyData = try JSONSerialization.jsonObject(with: encoderBodyData, options: .allowFragments) as! [String: String]
//
//        var combinedData = bodyPrepareData.merging(bodyData) { $1 }
//
//        //swiftlint:disable:next force_cast
//        let sig = sigUtils.hmac(algorithm: .SHA1, url: sigUtils.oauth1SignatureBaseString(path, combinedData as! [String: String]), secret: session.secret)
//        combinedData["sig"] = sig
//
//        return combinedData
//
//    }
//}
