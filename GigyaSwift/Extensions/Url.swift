//
//  Url.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 29/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension URL {
    subscript(queryParam: String) -> String? {
        guard let url = URLComponents(string: self.absoluteString) else { return nil }
        if let parameters = url.queryItems {
            return parameters.first(where: { $0.name == queryParam })?.value
        } else if let paramPairs = url.fragment?.components(separatedBy: "#").last?.components(separatedBy: "&") {
            for pair in paramPairs where pair.contains(queryParam) {
                if let index = pair.firstIndex(of: "=") {

                    var getString = pair[index...]

                    getString.removeFirst()

                    return String(getString)
                }
                return nil
            }
            return nil
        } else {
            return nil
        }
    }
}
