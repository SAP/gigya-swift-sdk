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

class GigyaConfig {
    var apiKey: String?
    var apiDomain: String?
    //TODO: Need to check if need isInitSdk
    var isInitSdk: Bool = false
    var gmid: String?
    var ucid: String?
//    var sessionInfo: SessionInfo?

}
