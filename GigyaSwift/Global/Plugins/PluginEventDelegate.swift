//
//  PluginEvent.swift
//  GigyaSwift
//
//  Created by Tal Mirmelshtein on 02/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public typealias PluginEventE = [String: Any]

public protocol PluginEventDelegate: class {
    func onError(error: GigyaResponseModel)
    func onEvent(event: PluginEvent)
}

public enum PluginEvent {
    case onBeforeValidation(event : PluginEventE)
    case onBeforeSubmit(event: PluginEventE)
    case onSubmit(event: PluginEventE)
    case onAfterSubmit(event: PluginEventE)
    case onBeforeScreenLoad(event: PluginEventE)
    case onAfterScreenLoad(event: PluginEventE)
    case onFieldChanged(event: PluginEventE)
    case onHide(event: PluginEventE)
    case onLogin(account: GigyaAccountProtocol)
    case onLogout
    case onConnectionAdded
    case onConnectionRemoved
    case error(event: PluginEventE)
}
