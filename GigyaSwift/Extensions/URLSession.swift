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
        configuration.urlCache = URLCache(memoryCapacity: 0, diskCapacity: 0, diskPath: nil)
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        configuration.httpShouldSetCookies = false
        configuration.httpShouldUsePipelining = false
        configuration.urlCredentialStorage = nil

        return URLSession(configuration: configuration)
    }()
}
