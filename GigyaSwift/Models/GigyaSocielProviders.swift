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
    case line
    case wechat

}

public enum GigyaNativeSocielProviders: String, CaseIterable {
    case facebook
    case google = "googleplus"
    case line
    case wechat

    func getClassName() -> String {
        switch self {
        case .facebook:
            return "FacebookWrapper"
        case .google:
            return "GoogleWrapper"
        case .line:
            return "LineWrapper"
        case .wechat:
            return "WeChatWrapper"
        }
    }

    var description: String {
        switch self {
        case .facebook:
            return "Facebook"
        case .google:
            return"Google"
        case .line:
            return "Line"
        case .wechat:
            return "WeChat"
        }
    }
}
