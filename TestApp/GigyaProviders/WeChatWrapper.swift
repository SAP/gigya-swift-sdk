//
//  WeChatWrapper.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 02/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit
import GigyaSwift

class WeChatWrapper: NSObject, ProviderWrapperProtocol {

    var clientID: String? = {
        return Bundle.main.infoDictionary?["WeChatAppID"] as? String
    }()

    private var completionHandler: (_ jsonData: [String: Any]?, _ error: String?) -> Void = { _, _  in }

    required override init() {
        super.init()

    }

    func login(params: [String: Any]? = nil, viewController: UIViewController? = nil,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void) {
        completionHandler = completion
        if WXApi.isWXAppInstalled() == false {
            print("WeChat not installed in the device")
        }

        let request = SendAuthReq.init()
        request.scope = "snsapi_userinfo"
        request.state = ""

        WXApi.send(request)

        WXApi.sendAuthReq(request, viewController: viewController, delegate: self)
    }
}

extension WeChatWrapper: WXApiDelegate {
    func onResp(_ resp: BaseResp!) {
        guard resp.errCode == 0, let response: SendAuthResp = resp as? SendAuthResp else {
            completionHandler(nil, resp.errStr)
            return
        }

        let jsonData: [String: Any] = ["accessToken": response.code, "providerUID": clientID ?? ""]
        completionHandler(jsonData, nil)
    }
}
