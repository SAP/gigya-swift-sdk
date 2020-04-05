//
//  NssFlowManagerDelegate.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 30/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya

protocol NssFlowManagerDelegate: class {

    func getMainLoginClosure<T>() -> MainClosure<T>

    func getResolver() -> NssResolverModelProtocol? 

}
