//
//  DataResolver.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 12/08/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter

class DataResolver {
    func handleDataRequest(request: DataChannelEvent, params: [String: Any]?, response: @escaping FlutterResult) {
        guard
            let imageName = params?["url"] as? String,
            let image = UIImage(named: imageName),
            let data = image.pngData() else {
                response(nil)
                return
        }

        response(data)
    }
}
