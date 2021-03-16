//
//  OtpServiceProtocol.swift
//  GigyaAuth
//
//  Created by Shmuel, Sagi on 10/02/2021.
//  Copyright © 2021 Gigya. All rights reserved.
//

import Foundation

public protocol OtpServiceProtocol {

    /**
     This method is used to trigger a Phone Number OTP Login flow.
     Returns a vToken, and sends an email containing the authentication code to the user.

     - Parameter phoneNumber: User's phone number.
     - Parameter params:        .
     */

    func login<T>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void)

    func login<T>(phone: String, params: [String: Any], completion: @escaping (GigyaOtpResult<T>) -> Void)

    func update<T>(phone: String, completion: @escaping (GigyaOtpResult<T>) -> Void)

    func update<T>(phone: String, params: [String: Any], completion: @escaping (GigyaOtpResult<T>) -> Void)

}
