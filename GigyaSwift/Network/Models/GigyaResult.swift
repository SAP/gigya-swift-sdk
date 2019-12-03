//
//  GigyaUser.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 05/03/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

@frozen
public enum GigyaResult<Response> {
    case success(data: Response) // success with data
    case failure(NetworkError) // failure with error
}
