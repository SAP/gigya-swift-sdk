//
//  WebAuthnAttestationUtils.swift
//  Gigya
//
//  Created by Sagi Shmuel on 24/07/2022.
//  Copyright © 2022 Gigya. All rights reserved.
//

import AuthenticationServices

struct WebAuthnAttestationUtils {
    @available(iOS 15.0, *)
    func makeRegisterData(object: ASAuthorizationPlatformPublicKeyCredentialRegistration) -> [String: Any] {
        let response: [String: String] = [
            "attestationObject": object.rawAttestationObject!.toBase64Url(),
            "clientDataJSON": object.rawClientDataJSON.toBase64Url()
        ]
        
        let attestation: [String: Any] = [
            "id": object.credentialID.toBase64Url(),
            "rawId": object.credentialID.toBase64Url(),
            "type": "public-key",
            "response": response
        ]
        
        return attestation
    }
    
    @available(iOS 15.0, *)
    func makeLoginData(object: ASAuthorizationPlatformPublicKeyCredentialAssertion) -> [String: Any] {
        let response: [String: String] = [
            "authenticatorData": object.rawAuthenticatorData.toBase64Url(),
            "clientDataJSON": object.rawClientDataJSON.toBase64Url(),
            "signature": object.signature.toBase64Url(),
            "userHandle": object.userID.toBase64Url()
        ]
        
        let attestation: [String: Any] = [
            "id": object.credentialID.toBase64Url(),
            "rawId": object.credentialID.toBase64Url(),
            "type": "public-key",
            "response": response
        ]
        
        return attestation
    }
}