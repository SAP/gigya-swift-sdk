//
//  GigyaService.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import Foundation
import Gigya

class GigyaService {
    lazy var shared = Gigya.sharedInstance(AccountModel.self)
}
