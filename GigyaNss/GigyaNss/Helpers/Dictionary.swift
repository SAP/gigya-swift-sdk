//
//  Dict.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 08/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
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

extension String {
    func convertStringToDictionary() -> [String: AnyObject]? {
       if let data = self.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
}
