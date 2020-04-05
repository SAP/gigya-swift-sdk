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

final class FlowManager<T: GigyaAccountProtocol> {

    // Flow handling
    private let flowFactory: ActionFactory<T>

    private var currentAction: NssAction<T>?

    // storage relevent interruptions
    //TODO: change to only one resolver
    private var currentResolver: NssResolverModelProtocol?

    // main result handler (for Login / Register)
    private var mainLoginClosure: MainClosure<T> = { _ in }

    // current result to dart when using interruption
    private var engineResultHandler: FlutterResult?

    // initalize new flow
    init(flowFactory: ActionFactory<T>) {
        self.flowFactory = flowFactory

        initClosure()
    }

    private func initClosure() {
        mainLoginClosure = { [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success:
                let resultData = ["errorCode": 0, "errorMessage": "", "callId": "", "statusCode": 200] as [String : Any]

                self.engineResultHandler?(resultData)

                // dispose current resolver
                self.disposeResolver()
            case .failure(let error):
                if let interrupt = error.interruption {
                    switch interrupt {
                    case .pendingRegistration(resolver: let resolver):
                        self.currentResolver = NssResolverModel<PendingRegistrationResolver<T>>(interrupt: interrupt.description, resolver: resolver)
                        break
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

    private func disposeResolver() {
        currentResolver = nil
    }

    // set the current action
    func setCurrent(action: Action, response: @escaping FlutterResult) {
        currentAction = flowFactory.create(identifier: action)
        currentAction?.delegate = self
        currentAction?.initialize(response: response)
    }

    func next(method: ApiChannelEvent, params: [String : Any]?, response: @escaping FlutterResult) {
        engineResultHandler = response
        currentAction?.next(method: method, params: params)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

extension FlowManager: NssFlowManagerDelegate {
    func getMainLoginClosure<T: GigyaAccountProtocol>() -> MainClosure<T> {
        return self.mainLoginClosure as! MainClosure<T>
    }

    func getResolver() -> NssResolverModelProtocol? {
        guard let resolver = currentResolver else {
            return nil
        }

        return resolver
    }
}
