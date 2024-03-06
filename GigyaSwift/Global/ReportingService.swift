//
//  ReportingService.swift
//  Gigya
//
//  Created by Shmuel, Sagi on 14/12/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Foundation

public final class ReportingService {
    private let networkProvider: NetworkProvider
    private let config: GigyaConfig

    var enable = false

    enum Priority: String {
        case info = "INFO"
        case error = "ERROR"
    }

    init(networkProvider: NetworkProvider, config: GigyaConfig) {
        self.networkProvider = networkProvider
        self.config = config
    }

    func sendErrorReport(msg: String, details: [String: Any], priority: Priority = .info) {
        guard enable else {
            return
        }

        let url = "https://accounts.\(config._apiDomain ?? "")"
        let params: [String: Any] = [
            "message": msg,
            "details": details,
            "apikey": config.apiKey ?? "",
            "sdkVersion": InternalConfig.General.version,
            "priority": priority.rawValue
        ]

        let model = ApiRequestModel(method: "sdk.errorReport", params: params)
        networkProvider.unsignRequest(url: url, model: model, method: .post) { response, error in
            guard error == nil else {
                GigyaLogger.log(with: self, message: "sendErrorReport: fail")
                return
            }

            GigyaLogger.log(with: self, message: "sendErrorReport: success")
        }
    }
}
