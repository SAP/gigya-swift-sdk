//
//  NativeScreenSetsViewModel.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 18/02/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Flutter
import Gigya

typealias NssHandler<T: GigyaAccountProtocol> = ((NssEvents<T>) -> Void)

class NativeScreenSetsViewModel<T: GigyaAccountProtocol>: NSObject, UIAdaptivePresentationControllerDelegate {
    
    var dismissClosure: () -> Void = {}
    var closeClosure: () -> Void = {}

    var screenChannel: ScreenChannel?
    var apiChannel: ApiChannel?
    var logChannel: LogChannel?
    var dataChannel: DataChannel?
    var screenEventsChannel: EventsChannel?

    let flowManager: FlowManager<T>
    let busnessApi: BusinessApiDelegate
    let dataResolver: DataResolver
    var eventsClosuresManager: EventsClosuresManager?

    var imagePickerVc: ImagePickerViewController?

    var engine: FlutterEngine?

    var eventHandler: NssHandler<T>? = { _ in }

    init(mainChannel: ScreenChannel, apiChannel: ApiChannel, logChannel: LogChannel, dataChannel: DataChannel, screenEventsChannel: EventsChannel,
         dataResolver: DataResolver, busnessApi: BusinessApiDelegate, flowManager: FlowManager<T>, eventHandler: NssHandler<T>?) {
        self.screenChannel = mainChannel
        self.apiChannel = apiChannel
        self.logChannel = logChannel
        self.dataChannel = dataChannel
        self.screenEventsChannel = screenEventsChannel
        self.flowManager = flowManager
        self.eventHandler = eventHandler
        self.busnessApi = busnessApi
        self.dataResolver = dataResolver
    }

    func loadChannels(with engine: FlutterEngine) {
        flowManager.currentVc = engine.viewController

        screenChannel?.initChannel(engine: engine)
        apiChannel?.initChannel(engine: engine)
        logChannel?.initChannel(engine: engine)
        dataChannel?.initChannel(engine: engine)
        screenEventsChannel?.initChannel(engine: engine)

        screenChannel?.methodHandler(scheme: ScreenChannelEvent.self) { [weak self] method, data, response in
            guard let self = self, let method = method else {
                return
            }

            switch method {
            case .action:
                guard
                    let flowId = data?["actionId"] as? String,
                    let flow = NssAction(rawValue: flowId),
                    let screenId = data?["screenId"] as? String
                    else {
                    return
                }

                let expressions = data?["expressions"] as? [String : String] ?? [:]

                self.flowManager.setCurrent(action: flow, response: response, expressions: expressions)
                self.flowManager.currentScreenId = screenId

            case .link:
                guard let stringUrl = data?["url"] as? String,
                    let url = URL(string: stringUrl) else { return }

                UIApplication.shared.open(url)
            case .dismiss:
                self.dismissClosure()
                self.eventHandler?(.canceled)
            case .canceled:
                self.dismissClosure()
                self.eventHandler?(.canceled)
            }
        }

        apiChannel?.methodHandler(scheme: ApiChannelEvent.self) { [weak self] method, data, response in
            guard let self = self, let method = method else {
                return
            }
            self.flowManager.next(method: method, params: data, response: response)

            GigyaLogger.log(with: self, message: "next: \(method)")
        }

        logChannel?.methodHandler(scheme: LogChannelEvent.self, { [weak self] (method, data, response) in
            guard let self = self, let method = method else {
                return
            }

            switch method {
            case .debug:
                GigyaLogger.log(with: self, message: data?["message"] as? String ?? "")
            case .error:
                GigyaLogger.error(with: GigyaNss.self, message: data?["message"] as? String ?? "")
            }
        })

        dataChannel?.methodHandler(scheme: DataChannelEvent.self, { [weak self] (method, data, response) in
            guard let self = self, let method = method else {
                return
            }

            switch method {
            case .imageResource:
                self.dataResolver.handleDataRequest(request: method, params: data, response: response)
            case .pickImage:
                guard let vc = self.flowManager.currentVc else {
                    GigyaLogger.log(with: self, message: "ViewController not found")
                    return
                }

                self.imagePickerVc = ImagePickerViewController()

                self.imagePickerVc?.didSelectImage = { [weak self] image in
                    self?.flowManager.next(method: .api, params: ["api": "setProfilePhoto", "image": image.pngData() ?? Data()], response: response)
                    self?.imagePickerVc = nil
                }

                self.imagePickerVc?.didCancel = { [weak self] in
                    self?.imagePickerVc = nil
                }

                self.imagePickerVc?.showSelectPicker(vc: vc, text: data?["text"] as? String)


            }
        })

        screenEventsChannel?.methodHandler(scheme: EventsChannelEvent.self, { [weak self] (method, data, response) in
            guard
                let self = self,
                let method = method,
                let screenId = data?["sid"] as? String,
                let screenClosure = self.eventsClosuresManager?[screenId]
            else {
                response(["data": [:]])
                return
            }

            let screen = ScreenEventModel()
            screen.data = data?["data"] as? [String: Any] ?? [:]
            screen.engineResponse = response

            switch method {
            case .screenDidLoad:
                screenClosure(.screenDidLoad)

                response(nil)
            case .routeFrom:

                screen.previousRoute = screen.data["pid"] as? String ?? ""

                screenClosure(.routeFrom(screen: screen))

            case .routeTo:

                screen.nextRoute = screen.data["nid"] as? String ?? ""

                screenClosure(.routeTo(screen: screen))

            case .submit:
                screenClosure(.submit(screen: screen))

            case .fieldDidChange:
                let fieldModel = FieldEventModel(id: screen.data["field"] as? String ?? "", oldVal: screen.data["from"] as? String, newVal: screen.data["to"] as? String)

                screenClosure(.fieldDidChange(screen: screen, field: fieldModel))
            }
        })
    }

    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        closeClosure()
    }

    deinit {
        GigyaLogger.log(with: self, message: "deinit")
    }
}

