//
//  SchemaHelper.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 28/06/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation
import Gigya

class SchemaHelper {
    private let busnessApi: BusinessApiDelegate

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    func getSchema(res: @escaping (([String: Any]) -> Void)) {
        busnessApi.sendApi(api: "accounts.getSchema", params: [:]) { (result) in
            switch result {
            case .success(data: let data):
                let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data)) as? [String: AnyObject]
                res(decodedObject ?? [:])
            case .failure(_):
                GigyaLogger.log(with: self, message: "faild to fetch schema")
                break
            }
        }
    }

}
