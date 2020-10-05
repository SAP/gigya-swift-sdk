//
//  SignatureUtils.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 24/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import CommonCrypto

class SignatureUtils {

    static func prepareSignature(config: GigyaConfig, persistenceService: PersistenceService, session: GigyaSession?, path: String, params: [String: Any] = [:]) throws -> [String: Any] {
        var timestamp: String?
        var nonce: String?
        var session: GigyaSession? = session
        var token: String? = session?.token

        if session != nil {
            timestamp = String(Int(Date().timeIntervalSince1970 + config.timestampOffset))
            nonce = String(timestamp!) + "_" + String(describing: arc4random())
        }

        if path.contains(GigyaDefinitions.API.getSdkConfig) {
            // clear data for getSdkConfig request
            session = nil
            token = nil
            timestamp = nil
            nonce = nil
        }
        //swiftlint:disable:next line_length
         let signatureModel = GigyaRequestSignature(oauthToken: token, apikey: config.apiKey!, nonce: nonce, timestamp: timestamp, ucid: persistenceService.ucid, gmid: persistenceService.gmid)

        let encoderPrepareData = try JSONEncoder().encode(signatureModel)
        let bodyPrepareData = try JSONSerialization.jsonObject(with: encoderPrepareData, options: .allowFragments) as! [String: Any]

        let combinedData = bodyPrepareData.merging(params) { $1 }

        var newParams: [String: Any] = combinedData.mapValues { value -> String in
            if let isDictionary = value as? [String: Any] {

                return isDictionary.asJson.replacingOccurrences(of: "\\/", with: "/")
            } else {
                return "\(value)"
            }
        }

        if let session = session {
            let sig = hmac(algorithm: .SHA1, url: oauth1SignatureBaseString(config.apiDomain ,path, newParams), secret: session.secret)

            newParams["sig"] = sig
        }

        return newParams
    }
    
    private static func oauth1SignatureBaseString(_ domain: String ,_ sMethod: String, _ paramsToSend: [String: Any]) -> String {
        let method = "POST"
        let url =  URL(string: "https://\(sMethod.components(separatedBy: ".").first!).\(domain)/\(sMethod)")!
        let urlAllowed = NSCharacterSet(charactersIn: GigyaDefinitions.charactersAllowedInSig).inverted

        let params = paramsToSend.mapValues { value in return "\(value)" }

        let bodyString: String = params.sorted(by: <).reduce("") { "\($0)\($1.0)=\($1.1.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? "")&" }

        let baseString = "\(method)&\(url.description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&\(bodyString.dropLast().addingPercentEncoding(withAllowedCharacters: urlAllowed)!)".replacingOccurrences(of: ":", with: "%3A")

        return baseString
    }

    private static func hmac(algorithm: CryptoAlgorithm, url: String, secret: String) -> String {
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        let decodedSecret = Data(base64Encoded: secret, options: .ignoreUnknownCharacters)!
        let decodedCount = decodedSecret.count

        let secretBytes = decodedSecret.withUnsafeBytes { (dataBytes) -> [Int8] in
            let pointer: UnsafePointer<Int8> = dataBytes.baseAddress!.assumingMemoryBound(to: Int8.self)

            let buffer = UnsafeBufferPointer(start: pointer,
                                             count: decodedCount)
            return [Int8](buffer)
        }

        let str = Array(url.utf8CString)
        let strLen = str.count-1

        CCHmac(algorithm.HMACAlgorithm, secretBytes, decodedCount, str, strLen, result)

        let data = Data(bytes: result, count: digestLen)
        return data.base64EncodedString().addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
    }

}

enum CryptoAlgorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512

    var HMACAlgorithm: CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:      result = CommonCrypto.kCCHmacAlgMD5
        case .SHA1:     result = CommonCrypto.kCCHmacAlgSHA1
        case .SHA224:   result = CommonCrypto.kCCHmacAlgSHA224
        case .SHA256:   result = CommonCrypto.kCCHmacAlgSHA256
        case .SHA384:   result = CommonCrypto.kCCHmacAlgSHA384
        case .SHA512:   result = CommonCrypto.kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }

    var digestLength: Int {
        var result: Int32 = 0
        switch self {
        case .MD5:      result = CC_MD5_DIGEST_LENGTH
        case .SHA1:     result = CC_SHA1_DIGEST_LENGTH
        case .SHA224:   result = CC_SHA224_DIGEST_LENGTH
        case .SHA256:   result = CC_SHA256_DIGEST_LENGTH
        case .SHA384:   result = CC_SHA384_DIGEST_LENGTH
        case .SHA512:   result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
}
