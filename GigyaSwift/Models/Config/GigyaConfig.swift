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
    public var apiDomain: String = InternalConfig.General.sdkDomain

    public var sessionVerificationInterval: Double?

    internal var timestampOffset: Double = 0
    internal var requestTimeout = InternalConfig.Network.requestTimeoutDefult
}
