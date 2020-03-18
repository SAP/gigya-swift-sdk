//
//  AccountFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import Gigya
import Flutter

class AccountFlow<T: GigyaAccountProtocol>: NssFlow {
    var busnessApi: BusinessApiDelegate

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
        busnessApi.callGetAccount(dataType: T.self, params: ["include": includeAll, "extraProfileFields": extraProfileFieldsAll]) { (result) in
            switch result {
            case .success(let data):
                guard let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data)) as? [String: AnyObject] else {
                    assertionFailure("Failed to serialize account object")
                    return
                }

                response(decodedObject)
            case .failure(let error):
                GigyaLogger.log(with: AccountFlow.self, message: "initialize() failed with: \(error.localizedDescription)")

                response(FlutterError(code: "500", message: error.localizedDescription, details: nil))
            }
        }
    }

    override func next(method: ApiChannelEvent, params: [String: Any]?, response: @escaping FlutterResult) {
        switch method {
        case .submit:
            break
        default:
            break
        }
    }
}
