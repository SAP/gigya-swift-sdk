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
}

public protocol ScreenSetsExternalBuilderProtocol {
    
    func initialRoute(name: String) -> BuilderOptions
    func events<B: GigyaAccountProtocol>(_ obj: B.Type, closure: @escaping (NssEvents<B>) -> Void) -> BuilderOptions

}

public protocol ScreenSetsActionsBuilderProtocol {
    func show(viewController: UIViewController)
}
