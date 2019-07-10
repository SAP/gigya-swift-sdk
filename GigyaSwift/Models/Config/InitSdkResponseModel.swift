//
//  InitSdkResponseModel.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 02/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

struct InitSdkResponseModel: Codable {
    let ids: InitSdkIdsModel
}

struct InitSdkIdsModel: Codable {
    let ucid: String
    let gmid: String
}
