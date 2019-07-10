//
//  Dictionary.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 09/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension Dictionary {

    var asJson: String {

        if let jsonData: Data = try? JSONSerialization.data(withJSONObject: self, options:[]),
            let result = String(data: jsonData, encoding: .utf8) {
            return result
        }

        return ""
    }
}
