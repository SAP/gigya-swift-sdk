//
//  Decode+EncodeUtils.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 17/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class DecodeEncodeUtils {

    static func decode<T>(fromType: T.Type, data: Data) throws -> T where T: Codable {
        do {
            let decodedObject = try JSONDecoder().decode(fromType, from: data)
            return decodedObject
        } catch let error {
            throw error
        }
    }

    static func parsePlistConfig() -> PlistConfig {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return PlistConfig(apiKey: "", apiDomain: "") }
        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(PlistConfig.self, from: data)
        } catch let error {
            preconditionFailure("Can't get the .plist file: \(error)")
        }
    }

}
