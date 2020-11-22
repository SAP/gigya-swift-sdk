//
//  BuilderOptionsProtocol.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 20/01/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import UIKit
import Gigya

public typealias BuilderOptions = ScreenSetsExternalBuilderProtocol & ScreenSetsActionsBuilderProtocol

public protocol ScreenSetsMainBuilderProtocol {
    func load(withAsset asset: String) -> BuilderOptions

    func load(screenSetId id: String) -> BuilderOptions
}

public protocol ScreenSetsExternalBuilderProtocol {
    
    func initialRoute(name: String) -> BuilderOptions

    func lang(name: String) -> BuilderOptions

    func events<B: GigyaAccountProtocol>(_ scheme: B.Type, handler: @escaping (NssEvents<B>) -> Void) -> BuilderOptions

    func events(handler: @escaping (NssEvents<GigyaAccount>) -> Void) -> BuilderOptions

    func eventsFor(screen: String, handler: @escaping (NssScreenEvent) -> Void) -> BuilderOptions

}

public protocol ScreenSetsActionsBuilderProtocol {
    func show(viewController: UIViewController)
}
