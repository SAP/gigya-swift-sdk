//
//  GigyaSocielProviders.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 12/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum GigyaSocielProviders: String {
    case facebook
    case google = "googleplus"
    case yahoo
    case twitter
    
    static func byName(name: String) -> GigyaSocielProviders? {
        return self.init(rawValue: name)
    }
}
