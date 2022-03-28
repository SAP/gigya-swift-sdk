//
//  PKCEHelper.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 28/10/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation
import CryptoKit

@available(iOS 13.0, *)
struct PKCEHelper {

    typealias PKCECode = String

    let verifier: PKCECode

    let challenge: PKCECode

    init() throws {
        verifier = PKCEHelper.generateCodeVerifier()
        challenge = try PKCEHelper.codeChallenge(fromVerifier: verifier)
    }

    static func codeChallenge(fromVerifier verifier: PKCECode) throws -> PKCECode {
        guard let verifierData = verifier.data(using: .ascii) else {
            throw PKCEError.improperlyFormattedVerifier
        }

        let challengeHashed = SHA256.hash(data: verifierData)
        let challengeBase64Encoded = Data(challengeHashed).base64URLEncodedString

        return challengeBase64Encoded
    }

    static func generateCodeVerifier() -> PKCECode {

        do {

            let rando = try PKCEHelper.generateCryptographicallySecureRandomOctets(count: 32)
            return Data(bytes: rando, count: rando.count).base64URLEncodedString

        } catch {

            return generateBase64RandomString(ofLength: 43)
        }
    }

    private static func generateCryptographicallySecureRandomOctets(count: Int) throws -> [UInt8] {
        var octets = [UInt8](repeating: 0, count: count)
        let status = SecRandomCopyBytes(kSecRandomDefault, octets.count, &octets)

        if status == errSecSuccess {
            return octets
        } else {
            throw PKCEError.failedToGenerateRandomOctets
        }
    }

    private static func generateBase64RandomString(ofLength length: UInt8) -> PKCECode {
        let base64 = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        return String((0..<length).map{ _ in base64.randomElement()! })
    }

    enum PKCEError: Error {
        case failedToGenerateRandomOctets
        case improperlyFormattedVerifier
    }
}

extension Data {
    var base64URLEncodedString: String {

        base64EncodedString()
            .replacingOccurrences(of: "=", with: "") // Remove any trailing '='s
            .replacingOccurrences(of: "+", with: "-") // 62nd char of encoding
            .replacingOccurrences(of: "/", with: "_") // 63rd char of encoding
            .trimmingCharacters(in: .whitespaces)
    }
}
