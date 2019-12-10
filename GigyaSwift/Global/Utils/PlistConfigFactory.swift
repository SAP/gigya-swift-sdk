//
//  PlistConfigFactory.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 10/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

final class PlistConfigFactory {
    func parsePlistConfig() -> PlistConfig? {
        guard let url = Bundle.main.url(forResource: "Info", withExtension: "plist") else { return nil }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            return try decoder.decode(PlistConfig.self, from: data)
        } catch let error {
            preconditionFailure("Can't get the .plist file: \(error)")
        }
    }
}
