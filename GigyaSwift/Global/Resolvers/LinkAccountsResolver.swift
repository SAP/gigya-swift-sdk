//
//  LinkAccountsResolver.swift
//  GigyaSwift
//
//  Created by Shmuel, Sagi on 13/05/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Foundation

public class LinkAccountsResolver<T> {

    let completion: (GigyaLoginResult<T>) -> Void

    weak var businessDelegate: BusinessApiDelegate?

    init(businessDelegate: BusinessApiDelegate, completion: @escaping (GigyaLoginResult<T>) -> Void) {
        self.completion = completion
        self.businessDelegate = businessDelegate
        
        start()
    }

    private func start() {

    }
}
