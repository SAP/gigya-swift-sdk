//
//  LinkAccountAction.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 27/10/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter
import UIKit

class LinkAccountAction<T: GigyaAccountProtocol>: Action<T> {
    var publishPhotoOnSubmit = false

    // resolver for interruption
    var linkAccountResolver: NssResolverModel<LinkAccountsResolver<T>>?

    init(busnessApi: BusinessApiDelegate, jsEval: JsEvaluatorHelper) {
        super.init()
        self.busnessApi = busnessApi
        self.jsEval = jsEval
    }

    override func initialize(response: @escaping FlutterResult, expressions: [String: String]) {

        if let resolverModel = delegate?.getResolver() as? NssResolverModel<LinkAccountsResolver<T>> {
            // storage refrence to the resolver
            self.linkAccountResolver = resolverModel

            // set regtoken as a params to request


            guard let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(resolverModel.resolver?.conflictingAccount)) as? [String: AnyObject] else {
                assertionFailure("Failed to serialize account object")
                return
            }

            let data = ["conflictingAccount": decodedObject]

            response(doExpressions(data: data, expressions: expressions))

        }
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        switch method {
        case .submit:
            guard let loginId = params?["loginID"] as? String,
                  let password = params?["password"] as? String else {
                return
            }

            linkAccountResolver?.resolver?.linkToSite(loginId: loginId, password: password)
        case .socialLogin:
            guard
                let vc = delegate?.getEngineVc(),
                let provider = params?["provider"] as? String,
                let socialProvider = GigyaSocialProviders(rawValue: provider) else {
                return
            }

            linkAccountResolver?.resolver?.linkToSocial(provider: socialProvider, viewController: vc)

        default:
            break
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
