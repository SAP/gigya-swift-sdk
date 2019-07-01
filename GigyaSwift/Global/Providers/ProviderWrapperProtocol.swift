//
//  ProviderWrapperProtocol.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 23/04/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import UIKit

@objc public protocol ProviderWrapperProtocol {
    init()
    
    var clientID: String? { get set }
    
    func login(params: [String: Any]?, viewController: UIViewController?,
               completion: @escaping (_ jsonData: [String: Any]?, _ error: String?) -> Void)

    @objc optional func logout()

}
