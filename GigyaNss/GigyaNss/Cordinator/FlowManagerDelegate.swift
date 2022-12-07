//
//  NssFlowManagerDelegate.swift
//  GigyaNss
//
//  Created by Shmuel, Sagi on 30/03/2020.
//  Copyright © 2020 Gigya. All rights reserved.
//

import Gigya
import Flutter

protocol FlowManagerDelegate: AnyObject {

    func getMainLoginClosure<T: GigyaAccountProtocol>(obj: T.Type) -> MainClosure<T>

    func getGenericClosure() -> ((GigyaApiResult<GigyaDictionary>) -> Void)

    func getApiClosure() -> ((GigyaApiResult<GigyaDictionary>, String) -> Void)

    func getEngineResultClosure() -> FlutterResult?

    func getResolver() -> NssResolverModelProtocol?

    func getEngineVc() -> UIViewController?

}
