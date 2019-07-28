//
//  URLSession.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 24/07/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

extension URLSession {
    // internal shared instance of URLSession
    internal static var sharedInternal: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.httpShouldSetCookies = false

        return URLSession(configuration: configuration)
    }()
}
