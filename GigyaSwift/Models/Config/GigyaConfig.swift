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
    var apiKey: String?
    var apiDomain: String = InternalConfig.General.sdkDomain
    
}
