//
//  GigyaApiResult.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 19/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum GigyaApiResult<Response> {
    case success(data: Response)
    case failure(NetworkError)
}
