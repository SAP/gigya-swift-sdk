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

 https://developers.gigya.com/display/GD/Social+Login#SocialLogin-SupportedProviders
 */
public enum GigyaSocialProviders {

    case facebook
    case google
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
    case orangeFrance
    case paypaloauth
    case tencentQq
    case renren
    case sinaWeibo
    case spiceworks
    case vkontakte
    case wordpress
    case xing
    case yahooJapan
    case apple
    case web(provider: String)

    static var webValue: String?

    func isRequiredSdk() -> Bool {
        switch self {
        case .facebook, .wechat, .google:
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

    var rawValue: String {
        switch self {
        case .google:
            return "googleplus"
        case .orangeFrance:
            return "orange france"
        case .tencentQq:
            return "tencentQq"
        case .sinaWeibo:
            return "sina weibo"
        case .yahooJapan:
            return "yahoo japan"
        case .web(let provider):
            return provider
        default:
            return String(describing: self)
        }

    }

    public init?(rawValue: String) {
        switch rawValue.lowercased() {
        case "facebook":
            self = .facebook
        case "google", "googleplus":
            self = .google
        case "yahoo":
            self = .yahoo
        case "twitter":
            self = .twitter
        case "line":
            self = .line
        case "wechat":
            self = .wechat
        case "amazon":
            self = .amazon
        case "blogger":
            self = .blogger
        case "foursquare":
            self = .foursquare
        case "instagram":
            self = .instagram
        case "kakao":
            self = .kakao
        case "linkedin":
            self = .linkedin
        case "livedoor":
            self = .livedoor
        case "messenger":
            self = .messenger
        case "mixi":
            self = .mixi
        case "naver":
            self = .naver
        case "netlog":
            self = .netlog
        case "odnoklassniki":
            self = .odnoklassniki
        case "orangefrance":
            self = .orangeFrance
        case "paypaloauth":
            self = .paypaloauth
        case "tencentqq":
            self = .tencentQq
        case "renren":
            self = .renren
        case "sinaweibo":
            self = .sinaWeibo
        case "spiceworks":
            self = .spiceworks
        case "vkontakte":
            self = .vkontakte
        case "wordpress":
            self = .wordpress
        case "xing":
            self = .xing
        case "yahoojapan":
            self = .yahooJapan
        case "apple":
            self = .apple
        default:
            self = .web(provider: rawValue)
        }
    }
}

/**
 The `GigyaNativeSocialProviders` it is list of supported native providers.
 */
public enum GigyaNativeSocialProviders: String, CaseIterable {
    public static var allCases: [GigyaNativeSocialProviders] {
        var casesAvailable: [GigyaNativeSocialProviders] = [.facebook, .google, .line ,.wechat]
        if #available(iOS 13.0, *) {
            casesAvailable.append(.apple)
        } else {
            GigyaLogger.log(with: self, message: "[.apple] not available")
        }

        return casesAvailable
    }

    case facebook
    case google = "googleplus"
    case line
    case wechat
    case apple = "apple"

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
        case .apple:
            return "AppleSignInWrapper"
        }
    }

}
