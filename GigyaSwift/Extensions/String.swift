//
//  String.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 01/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension String {
    
    subscript(queryParam: String) -> String? {
        let paramPairs = self.components(separatedBy: "&")
  
        for pair in paramPairs where pair.contains(queryParam) {
            if let index = pair.firstIndex(of: "=") {
                
                var getString = pair[index...]
                
                getString.removeFirst()
                
                return String(getString)
            }
            return nil
        }
        return nil
    }
    
    func asDictionary() -> [String: String] {
        var map = [String:String]()
        let decoded = self.removingPercentEncoding ?? ""
        for pair in decoded.components(separatedBy: "&") {
            let key = pair.components(separatedBy: "=")[0]
            let value = pair
                .components(separatedBy:"=")[1]
                .replacingOccurrences(of: "+", with: " ")
                .removingPercentEncoding ?? ""
            map[key] = value
        }
        return map
    }
}
