////
////  GigyaApi.swift
////  GigyaSwift
////
////  Created by Shmuel, Sagi on 05/03/2019.
////  Copyright © 2019 Gigya. All rights reserved.
////
//
import Foundation

@objc(GSSession)
public class GigyaSession: NSObject, NSCoding {
    var token: String = ""

    var secret: String = ""

    var lastLoginProvider = ""

    init?(sessionToken token: String, secret: String) {
        self.token = token
        self.secret = secret
    }

    public func encode(with aCoder: NSCoder) {
        aCoder.encode(self.token, forKey: "authToken")
        aCoder.encode(self.secret, forKey: "secret")
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init()

        guard let token = aDecoder.decodeObject(forKey: "authToken") as? String,
            let secret = aDecoder.decodeObject(forKey: "secret") as? String else { return }

        self.token = token
        self.secret = secret
    }

    func isValid() -> Bool {
        return !token.isEmpty && !secret.isEmpty
    }
}

