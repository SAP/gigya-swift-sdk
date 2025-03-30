//
//  SaptchUtil.swift
//  GigyaSwift
//
//  Created by Sagi Shmuel on 03/03/2025.
//  Copyright © 2025 Gigya. All rights reserved.
//

import CryptoKit

struct SaptchaUtils {
    @available(iOS 13.0, *)
    private func verifyChallenge(challengeId: String, pattern: String, i: Int) -> Bool {
        let value = "\(challengeId).\(i)".encodeWith(SHA512.self)
        
        if value.matches(pattern) {
            return true
        } else {
            return false
        }
    }
    
    @available(iOS 13.0, *)
    func verifySaptcha(jwt: String) -> Int {
        guard let jwt = jwt.jwtDecode() else { return -1 }
        guard let jti = jwt["jti"] as? String else { return -1 }
        guard let pattern = jwt["pattern"] as? String else { return -1 }
        
        var i = 0
        var isFinish: Bool = false
        
        while !isFinish {
            i += 1
            isFinish = verifyChallenge(challengeId: jti, pattern: pattern, i: i)
        }
        
        return i
    }
}
