//
//  NativeScreenSetsViewModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

class NativeScreenSetsViewModel<T: GigyaAccountProtocol>: CordinatorContainer<T>, UIAdaptivePresentationControllerDelegate {
    
    var dismissClosure: () -> Void = {}
    var closeClosure: () -> Void = {}

    var screenChannel: ScreenChannel?
    var apiChannel: ApiChannel?

    let flowFactory: FlowFactory<T>

    var engine: FlutterEngine?

    init(mainChannel: ScreenChannel, apiChannel: ApiChannel, flowFactory: FlowFactory<T>) {
        self.screenChannel = mainChannel
        self.apiChannel = apiChannel
        self.flowFactory = flowFactory
    }

    func loadChannels(with engine: FlutterEngine) {
        screenChannel?.initChannel(engine: engine)
        apiChannel?.initChannel(engine: engine)

        screenChannel?.methodHandler(scheme: ScreenChannelEvent.self) { [weak self] method, data, response in
            guard let self = self, let method = method else {
                return
            }

            switch method {
//            case .ignition:
//                let loadAsset = self.loaderHelper.fileToDic(name: asset)
//                response(loadAsset)
            case .flow:
                guard
                    let flowId = data?["flowId"] as? String,
                    let flow = Flow(rawValue: flowId) else {
                    return
                }

                let generateFlow = self.flowFactory.create(identifier: flow)

                self.add(id: flow, flow: generateFlow)
            case .dismiss:
                self.dismissClosure()
                self.removeAll()
            }
        }

        apiChannel?.methodHandler(scheme: ApiChannelEvent.self) { [weak self] method, data, response in
            guard let self = self, let method = method?.rawValue else {
                return
            }

            self.currentFlow?.next(method: method, params: data, response: response)
        }
    }


    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeClosure()
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}



