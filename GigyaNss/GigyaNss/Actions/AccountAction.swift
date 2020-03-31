//
//  AccountFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import Gigya
import Flutter

class SetAccountAction<T: GigyaAccountProtocol>: NssAction<T> {
    var busnessApi: BusinessApiDelegate

    // resolver for interruption
    var pendingRegResolver: NssResolverModel<PendingRegistrationResolver<T>>?

    let includeAll = "identities-active , identities-all , identities-global , loginIDs ," +
            " emails, profile, data, password, isLockedOut, lastLoginLocation, regSource, irank, rba, subscriptions, userInfo, preferences"
    let extraProfileFieldsAll = "languages, address, phones, education, educationLevel," +
            " honors, publications,  patents, certifications, professionalHeadline, bio, industry," +
            " specialties, work, skills, religion, politicalView, interestedIn, relationshipStatus," +
            " hometown, favorites, followersCount, followingCount, username, name, locale, verified, timezone, likes, samlData"

    init(busnessApi: BusinessApiDelegate) {
        self.busnessApi = busnessApi
    }

    override func initialize(response: @escaping FlutterResult) {

        var params = ["include": includeAll, "extraProfileFields": extraProfileFieldsAll]

        if let resolverModel = delegate?.getResolver(by: .pendingRegistration, as: PendingRegistrationResolver<T>.self) {
            // storage refrence to the resolver
            self.pendingRegResolver = resolverModel

            // set regtoken as a params to request
            params["regToken"] = resolverModel.resolver?.regToken ?? ""
        }

        busnessApi.callGetAccount(dataType: T.self, params: params) { (result) in
            switch result {
            case .success(let data):
                guard let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data)) as? [String: AnyObject] else {
                    assertionFailure("Failed to serialize account object")
                    return
                }

                response(decodedObject)
            case .failure(let error):
                GigyaLogger.log(with: SetAccountAction.self, message: "initialize() failed with: \(error.localizedDescription)")

                response(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        }
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?) {
        super.next(method: method, params: params)

        switch method {
        case .submit:
            if let resolver = pendingRegResolver?.resolver {
                // TODO: hard code setAccount, would send the data from the form the engine ready
                resolver.setAccount(params: ["profile": ["zip": "12345"]])

                delegate?.disposeResolver(by: .pendingRegistration)
            } else {
                busnessApi.callSetAccount(dataType: T.self, params: params ?? [:]) { (result) in
                    switch result {
                    case .success(data: let data):
                        break
                    case .failure(_):
                        break
                    }
                }
            }
            break
        default:
            break
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
