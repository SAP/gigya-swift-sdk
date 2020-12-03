//
//  NssFlow.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 19/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

protocol NssActionProtocol: class {
    var actionId: NssAction? { get set }

    var delegate: FlowManagerDelegate? { get set }

    var busnessApi: BusinessApiDelegate? { get set }

    var jsEval: JsEvaluatorHelper? { get set }

    func initialize(response: @escaping FlutterResult, expressions: [String: String])

    func next(method: ApiChannelEvent, params: [String: Any]?)
}

class Action<T: GigyaAccountProtocol>: NssActionProtocol {

    var actionId: NssAction?

    var busnessApi: BusinessApiDelegate?

    var jsEval: JsEvaluatorHelper?

    weak var delegate: FlowManagerDelegate?

    func initialize(response: @escaping FlutterResult, expressions: [String: String]) {
        response(doExpressions(data: [:], expressions: expressions))
    }

    func doExpressions( data: [String: Any], expressions: [String: String]) -> [String: Any] {
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

        busnessApi?.callSociallogin(provider: socialProvider, viewController: vc, params: [:], dataType: T.self, completion: delegate!.getMainLoginClosure(obj: T.self))

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
