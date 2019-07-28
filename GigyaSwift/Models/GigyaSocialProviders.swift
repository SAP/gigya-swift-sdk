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
}

/**
 The `GigyaNativeSocialProviders` it is list of supported native providers.
 */
public enum GigyaNativeSocialProviders: String, CaseIterable {
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
}
