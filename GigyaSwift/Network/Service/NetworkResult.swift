//
//  ApiResult.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 04/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public enum NetworkResult<Response> {
    case success(Response)
    case failure(NetworkError)
}
