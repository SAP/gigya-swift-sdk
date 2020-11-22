//
//  AccountFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//
import Gigya
import Flutter
import UIKit

class SetAccountAction<T: GigyaAccountProtocol>: Action<T> {
    var publishPhotoOnSubmit = false

    // resolver for interruption
    var pendingRegResolver: NssResolverModel<PendingRegistrationResolver<T>>?

    let includeAll = "identities-active , identities-all , identities-global , loginIDs ," +
            " emails, profile, data, password, isLockedOut, lastLoginLocation, regSource, irank, rba, subscriptions, userInfo, preferences"
    let extraProfileFieldsAll = "languages, address, phones, education, educationLevel," +
            " honors, publications,  patents, certifications, professionalHeadline, bio, industry," +
            " specialties, work, skills, religion, politicalView, interestedIn, relationshipStatus," +
            " hometown, favorites, followersCount, followingCount, username, name, locale, verified, timezone, likes, samlData"

    init(busnessApi: BusinessApiDelegate, jsEval: JsEvaluatorHelper) {
        super.init()
        self.jsEval = jsEval
        self.busnessApi = busnessApi
    }
    
    override func initialize(response: @escaping FlutterResult, expressions: [String: String]) {

        var params = ["include": includeAll, "extraProfileFields": extraProfileFieldsAll]

        if let resolverModel = delegate?.getResolver() as? NssResolverModel<PendingRegistrationResolver<T>> {
            // storage refrence to the resolver
            self.pendingRegResolver = resolverModel

            // set regtoken as a params to request
            params["regToken"] = resolverModel.resolver?.regToken ?? ""
        }

        busnessApi?.callGetAccount(dataType: T.self, params: params) { [weak self] (result) in
            switch result {
            case .success(let data):
                guard let decodedObject = try? JSONSerialization.jsonObject(with: JSONEncoder().encode(data)) as? [String: AnyObject] else {
                    assertionFailure("Failed to serialize account object")
                    return
                }

                response(self?.doExpressions(data: decodedObject, expressions: expressions))

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
                resolver.setAccount(params: params!)

            } else {
                var data: [String: Any] = [:];
                data["data"] = params?["data"]
                data["profile"] = params?["profile"]
                busnessApi?.callSetAccount(dataType: T.self, params: data, completion: self.apiClosure)

                if publishPhotoOnSubmit {
                    self.publishProfilePhoto()
                }
            }
        case .api:
            if
                let api = params?["api"] as? String,
                let imageData = params?["image"] as? Data,
                api == "setProfilePhoto" {
                setProfilePhoto(imageInBytes: imageData)
            }
        default:
            break
        }
    }

    func setProfilePhoto(imageInBytes: Data?) {
        let imageSize = Double(imageInBytes?.count ?? 0 ) / 1024 / 1024
        if imageSize >= 6 {
            let handler = self.delegate?.getGenericClosure()
            let error = try! GigyaResponseModel.makeError(errorCode: 413004, errorMessage: "Image size exceeds 6 MB")

            handler?(GigyaApiResult.failure(.gigyaError(data: error)))
        }

        let base64image = imageInBytes!.base64EncodedString(options: .init(rawValue: 0))

        busnessApi?.sendApi(api: "accounts.setProfilePhoto", params: ["photoBytes": base64image]) { [weak self] (result) in

            switch result {
            case .success:
                self?.publishPhotoOnSubmit = true
                GigyaLogger.log(with: self, message: "publishProfilePhoto: success")

                let returnImage = self?.delegate?.getEngineResultClosure()
                returnImage?(imageInBytes!)
            case .failure(let error):
                self?.publishPhotoOnSubmit = true
                GigyaLogger.log(with: self, message: "publishProfilePhoto: failed")

                let handler = self?.delegate?.getGenericClosure()
                handler?(.failure(error))
            }

        }
    }

    func publishProfilePhoto() {
        busnessApi?.sendApi(api: "accounts.publishProfilePhoto", params: [:]) { [weak self] (result) in
            switch result {
            case .success:
                GigyaLogger.log(with: self, message: "publishProfilePhoto: success")
            case .failure:
                GigyaLogger.log(with: self, message: "publishProfilePhoto: failed")
            }

            self?.publishPhotoOnSubmit = false
        }
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}
