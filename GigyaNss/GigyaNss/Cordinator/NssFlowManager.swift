//
//  NssFlowManager.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 29/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter
typealias MainClosure<T: GigyaAccountProtocol> = (GigyaLoginResult<T>) -> Void

final class NssFlowManager<T: GigyaAccountProtocol> {

    // Flow handling
    let flowFactory: ActionFactory<T>
    var currentFlow: NssAction<T>?

    // storage relevent interruptions
    var interruptions: [NssInterruptionsSupported: NssResolverModelProtocol] = [:]

    // main result handler (for Login / Register)
    private var mainLoginClosure: MainClosure<T> = { _ in }

    // current result to dart when using interruption
    var engineResultHandler: FlutterResult?

    // initalize new flow
    init(flowFactory: ActionFactory<T>) {
        self.flowFactory = flowFactory

        initClosure()
    }

    func initClosure() {
        mainLoginClosure = { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                let resultData = ["errorCode": 0, "errorMessage": "", "callId": "", "statusCode": 200] as [String : Any]

                self.engineResultHandler?(resultData)
            case .failure(let error):
                if let interrupt = error.interruption {
                    switch interrupt {
                    case .pendingRegistration(resolver: let resolver):
                        self.interruptions[interrupt.description] = NssResolverModel<PendingRegistrationResolver<T>>(interrupt: interrupt.description, resolver: resolver)
                    default:
                        break
                    }

                    switch error.error {
                    case .gigyaError(let data):
                        //TODO: Hardcoded sucess, will be change after engine can handling interruptions
                        let resultData = ["errorCode": 0, "errorMessage": "", "callId": "", "statusCode": 200] as [String : Any]
                        self.engineResultHandler?(resultData)

//                        response(FlutterError(code: "\(data.errorCode)", message: data.errorMessage, details: data.toDictionary().asJson))
                    default:
                        self.engineResultHandler?(FlutterError(code: "500", message: "", details: nil))
                    }
                }
            }
        }
    }

    // set the current action
    func setCurrent(action: Action, response: @escaping FlutterResult) {
        currentFlow = flowFactory.create(identifier: action)
        currentFlow?.delegate = self
        currentFlow?.initialize(response: response)
    }

    func next(method: ApiChannelEvent, params: [String : Any]?, response: @escaping FlutterResult) {
        engineResultHandler = response
        currentFlow?.next(method: method, params: params)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

extension NssFlowManager: NssFlowManagerDelegate {
    func getMainLoginClosure<T>() -> MainClosure<T> where T : GigyaAccountProtocol {
        return self.mainLoginClosure as! MainClosure<T>
    }

    func getResolver<R>(by interrupt: NssInterruptionsSupported, as: R.Type) -> NssResolverModel<R>? {
        guard let resolver = interruptions[interrupt] as? NssResolverModel<R> else {
            return nil
        }

        return resolver
    }

    func disposeResolver(by interrupt: NssInterruptionsSupported) {
        interruptions.removeValue(forKey: interrupt)
    }
}
