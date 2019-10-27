//
//  MockURLSession.swift
//  GigyaSwiftTests
//
//  Created by Shmuel, Sagi on 06/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

class URLProtocolMock: URLProtocol {
    // this dictionary maps URLs to test data
    static var testURLs = [String: Data]()

    // say we want to handle all types of request
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    // ignore this method; just send back what we were given
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        // if we have a valid URL…
        if let url = request.url {
            // …and if we have test data for that URL…
            print(url.absoluteString)
            if let data = URLProtocolMock.testURLs[url.absoluteString] {
                // …load it immediately.
                self.client?.urlProtocol(self, didLoad: data)
            }
        }

        // mark that we've finished
        self.client?.urlProtocolDidFinishLoading(self)
    }

    // this method is required but doesn't need to do anything
    override func stopLoading() { }
}
