//
//  GigyaSocielProviders.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 12/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
/**
 The `GigyaSocialProviders` it is list of supported providers.
 */
public enum GigyaSocialProviders: String {
    case facebook
    case google = "googleplus"
    case yahoo
    case twitter
    case line
    case wechat
    case amazon
    case blogger
    case foursquare
    case instagram
    case kakao
    case linkedin
    case livedoor
    case messenger
    case mixi
    case naver
    case netlog
    case odnoklassniki
    case orangeFrance = "orange france"
    case paypaloauth
    case tencentQq = "tencent qq"
    case renren
    case sinaWeibo = "sina weibo"
    case spiceworks
    case vkontakte
    case wordpress
    case xing
    case yahooJapan = "Yahoo Japan"
    case appleSignin

    func isOnlySdk() -> Bool {
        switch self {
        case .facebook, .wechat, .appleSignin:
            return true
        default:
            return false
        }
    }

    func isSupported() -> Bool {
        guard let provider = GigyaNativeSocialProviders(rawValue: self.rawValue) else { return true }

        if GigyaNativeSocialProviders.allCases.contains(provider) {
            return true
        }

        return false
    }
}

/**
 The `GigyaNativeSocialProviders` it is list of supported native providers.
 */
public enum GigyaNativeSocialProviders: String, CaseIterable {
    public static var allCases: [GigyaNativeSocialProviders] {
        var casesAvailable: [GigyaNativeSocialProviders] = [.facebook, .google, .line ,.wechat]
        if #available(iOS 13.0, *) {
            casesAvailable.append(.appleSignin)
        } else {
            GigyaLogger.log(with: self, message: "[.appleSignin] not available")
        }

        return casesAvailable
    }

    case facebook
    case google = "googleplus"
    case line
    case wechat
    case appleSignin

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
        case .appleSignin:
            return "AppleSignInWrapper"
        }
    }
}
