//
//  Dictionary.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension Dictionary {

    var asJson: String {
        do {

            let jsonData: Data = try JSONSerialization.data(withJSONObject: self, options:[])
            let result = String(data: jsonData, encoding: .utf8)
            return result ?? ""
        } catch {
            GigyaLogger.log(with: self, message: error.localizedDescription)
        }

        return ""

    }
}
