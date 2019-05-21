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

    func oauth1SignatureBaseString(_ sMethod: String, _ paramsToSend: [String: String]) -> String {
        let method = "POST"
        let url =  URL(string: "https://\(sMethod.components(separatedBy: ".").first!).\("")/\(sMethod)")!
        let urlAllowed = NSCharacterSet(charactersIn: "!*'();:@&=+$,/?%#[] ").inverted

        let sortedParams = paramsToSend.sorted(by: <)
        var query = ""

        for param in sortedParams {
            let value = param.value.addingPercentEncoding(withAllowedCharacters: urlAllowed) ?? ""
            query += "\(param.key)=\(value)&"
        }
        query = String(query.dropLast())

        let baseString = "\(method)&\(url.description.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&\(query.addingPercentEncoding(withAllowedCharacters: urlAllowed)!)"

        return baseString
    }

    func hmac(algorithm: CryptoAlgorithm, url: String, secret: String) -> String {
        let digestLen = algorithm.digestLength
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)

        let decodedSecret = Data(base64Encoded: secret, options: .ignoreUnknownCharacters)!
        let decodedCount = decodedSecret.count

        let secretBytes = decodedSecret.withUnsafeBytes { (pointer: UnsafePointer<Int8>) -> [Int8] in
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
