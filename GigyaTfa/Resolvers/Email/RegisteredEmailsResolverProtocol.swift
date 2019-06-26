//
//  IOCRegisteredEmailsResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 23/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation
import Gigya

public protocol RegisteredEmailsResolverProtocol {
    func getRegisteredEmails(completion: @escaping (RegisteredEmailsResult) -> Void)

    func sendEmailCode(with email: TFAEmail, completion: @escaping (RegisteredEmailsResult) -> Void)
}
