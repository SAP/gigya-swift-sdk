//
//  Decode+EncodeUtils.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 17/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class DecodeEncodeUtils {

    static func decode<T>(fromType: T.Type, data: Data) throws -> T where T: Codable {
        do {
            let decodedObject = try JSONDecoder().decode(fromType, from: data)
            return decodedObject
        } catch let error {
            throw error
        }
    }

    static func encodeToDictionary<T: Codable>(obj: T) throws -> [String: AnyObject] {
        do {
            let decodedObject = try JSONSerialization.jsonObject(with: JSONEncoder().encode(obj)) as? [String: AnyObject] ?? [:]

            return decodedObject
        } catch let error {
            throw error
        }
    }

    static func dataToDictionary(data: Data?) -> [String: AnyObject] {
        do {
            let dictionary = try JSONSerialization.jsonObject(with: data ?? Data(), options: [])

            return dictionary as! [String: AnyObject]
        } catch {
            return [:]
        }
    }

}
