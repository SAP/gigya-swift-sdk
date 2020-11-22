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

    //
    private var currentAction: Action<T>?

    // storage relevent interruptions
    private var currentResolver: NssResolverModelProtocol?

    // main result handler (for Login / Register)
    private var mainLoginClosure: MainClosure<T> = { _ in }

    private var genericClosure: (GigyaApiResult<GigyaDictionary>) -> Void = { _ in }

    // current result to dart when using interruption
    private var engineResultHandler: FlutterResult?

    // Current engine view controller
    weak var currentVc: UIViewController?

    // Current screen id - for events handler
    var currentScreenId: String?

    // events handler
    var eventsClosure: NssHandler<T>? = { _ in }

    // initalize new flow
    init(flowFactory: ActionFactory<T>, eventHandler: NssHandler<T>?) {
        self.flowFactory = flowFactory
        self.eventsClosure = eventHandler

        initClosure()
    }

    private func initClosure() {
        genericClosure = { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success:
                self.engineResultHandler?(GigyaResponseModel.successfullyResponse())
                self.eventsClosure?(.success(screenId: self.currentScreenId ?? "", action: self.currentAction?.actionId ?? .unknown, data: nil))

            case .failure(let error):
                self.engineResultHandler?(GigyaResponseModel.failedResponse(with: error))
                self.eventsClosure?(.error(screenId: self.currentScreenId ?? "", error: error))
            }
        }

        mainLoginClosure = { [weak self] result in
            guard let self = self else {
                return
            }

            switch result {
            case .success(let data):

                self.engineResultHandler?(GigyaResponseModel.successfullyResponse())

                // call to event handler
                self.eventsClosure?(.success(screenId: self.currentScreenId ?? "", action: self.currentAction?.actionId ?? .unknown, data: data))

                // dispose current resolver
                self.disposeResolver()
            case .failure(let error):
      
                if let interrupt = error.interruption {
                    switch interrupt {
                    case .pendingRegistration(resolver: let resolver):
                        self.currentResolver = NssResolverModel<PendingRegistrationResolver<T>>(interrupt: interrupt.description, resolver: resolver)
                    case .conflitingAccount(let resolver):
                        self.currentResolver = NssResolverModel<LinkAccountsResolver<T>>(interrupt: interrupt.description, resolver: resolver)
                    default:
                        break
                    }
                }

                self.eventsClosure?(.error(screenId: self.currentScreenId ?? "", error: error.error))

                var newError = error.error
                if case .providerError(data: "cancelled") = error.error {
                    newError = NetworkError.gigyaError(data: try! GigyaResponseModel.makeError(errorCode: 200001, errorMessage: "error-operation-canceled"))
                }

                self.engineResultHandler?(GigyaResponseModel.failedResponse(with: newError))

            }
        }
    }

    private func disposeResolver() {
        currentResolver = nil
        currentAction = nil
    }

    // set the current action
    func setCurrent(action: NssAction, response: @escaping FlutterResult, expressions: [String: String] = [:]) {
        currentAction = flowFactory.create(identifier: action)
        currentAction?.delegate = self
        currentAction?.initialize(response: response, expressions: expressions)
    }

    func next(method: ApiChannelEvent, params: [String : Any]?, response: @escaping FlutterResult) {
        engineResultHandler = response
        currentAction?.next(method: method, params: params)
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

extension FlowManager: FlowManagerDelegate {
    func getMainLoginClosure<T: GigyaAccountProtocol>(obj: T.Type) -> MainClosure<T> {
        return self.mainLoginClosure as! MainClosure<T>
    }

    func getGenericClosure() -> ((GigyaApiResult<GigyaDictionary>) -> Void) {
        return genericClosure
    }

    func getEngineResultClosure() -> FlutterResult? {
        return engineResultHandler
    }

    func getResolver() -> NssResolverModelProtocol? {
        guard let resolver = currentResolver else {
            return nil
        }

        return resolver
    }

    func getEngineVc() -> UIViewController? {
        return currentVc
    }
}
