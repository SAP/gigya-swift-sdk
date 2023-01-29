//
//  GigyaConfig.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 25/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

protocol GigyaConfigProtocol {
    var config: GigyaConfig { get set }
}

public class GigyaConfig {
    public var apiKey: String?
    
    internal var _apiDomain: String?
    public var apiDomain: String {
        get {
            if self.cnameEnable {
                return cname!
            }
            return self._apiDomain ?? InternalConfig.Storage.defaultApiDomain
        }
        
        set {
            self._apiDomain = newValue
        }
    }
    
    public var cname: String? {
        didSet {
            self.cname = (cname ?? "").isEmpty ? nil : cname
        }
    }
    
    public var cnameEnable: Bool {
        return cname != nil
    }

    public var sessionVerificationInterval: Double?

    internal var timestampOffset: Double = 0
    internal var requestTimeout = InternalConfig.Network.requestTimeoutDefult

    internal var accountConfig: GigyaAccountConfig?
}
