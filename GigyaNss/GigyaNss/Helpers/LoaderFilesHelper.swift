//
//  LoadHelper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 20/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Gigya

class LoaderFileHelper {
    func fileToDic(name: String) -> String {
        guard let filePath = Bundle.main.url(forResource: name, withExtension: "json") else {
            GigyaLogger.error(with: LoaderFileHelper.self, message: "json file not found.")
        }

        do {
            let data = try Data(contentsOf: filePath, options: .mappedIfSafe)
            return String(data: data, encoding: .utf8)!
        } catch {
            // handle error
        }

        return ""
    }
}
