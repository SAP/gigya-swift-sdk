//
//  NssFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

protocol NssActionProtocol: AnyObject {
    var actionId: NssAction? { get set }

    var delegate: FlowManagerDelegate? { get set }

    var businessApi: BusinessApiDelegate? { get set }

    var jsEval: JsEvaluatorHelper? { get set }

    func initialize(response: @escaping FlutterResult, expressions: [String: String])

    func next(method: ApiChannelEvent, params: [String: Any]?)
}

class Action<T: GigyaAccountProtocol>: NssActionProtocol {

    var actionId: NssAction?

    var businessApi: BusinessApiDelegate?

    var jsEval: JsEvaluatorHelper?
    
    var tempUid: String?
    
    var persistenceService: PersistenceService? = {
        return GigyaNss.shared.dependenciesContainer.resolve(PersistenceService.self)
    }()
    
    var webAuthnService: WebAuthnService<T>? = {
        return GigyaNss.shared.dependenciesContainer.resolve(WebAuthnService<T>.self)
    }()

    weak var delegate: FlowManagerDelegate?
    
    var globalData: [String: Any] {
        return ["Gigya": ["isLoggedIn": Gigya.sharedInstance(T.self).isLoggedIn(), "webAuthn":["isExists": webAuthnService?.passkeyForUser(uid: tempUid), "isSupported": webAuthnService?.isSupported ?? false]]]
    }

    func initialize(response: @escaping FlutterResult, expressions: [String: String]) {
        response(doExpressions(data: globalData, expressions: expressions))
    }

    func doExpressions( data: [String: Any], expressions: [String: String]) -> [String: Any] {
        let data = data.merging(globalData){ (_, new) in new }
        let jsExp = jsEval?.eval(data: data, expressions: expressions)
        var returnData: [String: Any] = [:]
        returnData["expressions"] = jsExp?.convertStringToDictionary() as AnyObject
        returnData["data"] = data
        return returnData
    }

    func next(method: ApiChannelEvent, params: [String : Any]?) {
        switch method {
        case .api:
            break
        case .socialLogin:
            socialLogin(params: params)
        case .webAuthnLogin:
            if #available(iOS 16.0, *) {
                self.webAuthnLogin()
            } else {
                GigyaLogger.log(with: self, message: "not supported in this iOS version.")
            }
        case .webAuthnRegister:
            if #available(iOS 16.0, *) {
                self.webAuthnRegister()
            } else {
                GigyaLogger.log(with: self, message: "not supported in this iOS version.")
            }
        case .webAuthnRevoke:
            if #available(iOS 16.0, *) {
                self.webAuthnRevoke()
            } else {
                GigyaLogger.log(with: self, message: "not supported in this iOS version.")
            }
        default:
            break
        }
    }

    func socialLogin(params: [String : Any]?) {
        guard
            let vc = delegate?.getEngineVc(),
            let provider = params?["provider"] as? String,
            let socialProvider = GigyaSocialProviders(rawValue: provider) else {
            return
        }

        businessApi?.callSociallogin(provider: socialProvider, viewController: vc, params: [:], dataType: T.self, completion: delegate!.getMainLoginClosure(obj: T.self))

    }
    
    
    @available(iOS 16.0, *)
    func webAuthnLogin() {
        guard
            let vc = delegate?.getEngineVc(),
            let webAuthnService = webAuthnService,
            let delegate = delegate else {
            return
        }
        
        Task {
            let result = await webAuthnService.login(viewController: vc)
            let closure = delegate.getMainLoginClosure(obj: T.self)
            closure(result)
        }
    }
    
    @available(iOS 16.0, *)
    func webAuthnRegister() {
        guard
            let vc = delegate?.getEngineVc(),
            let webAuthnService = webAuthnService,
            let delegate = delegate else {
            return
        }
        
        Task {
            let result = await webAuthnService.register(viewController: vc)
            let closure = delegate.getApiClosure()
            closure(result, ApiChannelEvent.webAuthnRegister.rawValue)
        }
    }
    
    @available(iOS 16.0, *)
    func webAuthnRevoke() {
        guard
            let webAuthnService = webAuthnService,
            let delegate = delegate else {
            return
        }
        
        Task {
            let result = await webAuthnService.revoke()
            let closure = delegate.getApiClosure()
            closure(result, ApiChannelEvent.webAuthnRevoke.rawValue)
        }
    }

    lazy var apiClosure: (GigyaApiResult<T>) -> Void = { [weak self] result in
        let mainClosure = self?.delegate?.getMainLoginClosure(obj: T.self)

        switch result {
        case .success(let data):
            mainClosure?(.success(data: data))
        case .failure(let error):
            let loginError = LoginApiError<T>(error: error, interruption: nil)

            mainClosure?(.failure(loginError))
        }
    }
}
