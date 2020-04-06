//
//  RegisterTotpResolver.swift
//  GigyaTfa
//
//  Created by Shmuel, Sagi on 24/06/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Gigya
public protocol TFAResolversProtocol { }

final public class RegisterTotpResolver<T: GigyaAccountProtocol>: TFAResolver<T>, RegisterTotpResolverProtocol, TFAResolversProtocol {

    internal let businessApiDelegate: BusinessApiDelegate
    internal let interruption: GigyaResponseModel
    internal let completionHandler: (GigyaLoginResult<T>) -> Void

    lazy var verifyTotpResolver: VerifyTotpResolver = {
        return VerifyTotpResolver(businessApiDelegate: self.businessApiDelegate, interruption: self.interruption, completionHandler: self.completionHandler)
    }()

    required init(businessApiDelegate: BusinessApiDelegate, interruption: GigyaResponseModel, completionHandler: @escaping (GigyaLoginResult<T>) -> Void) {
        self.businessApiDelegate = businessApiDelegate
        self.interruption = interruption
        self.completionHandler = completionHandler

        super.init(businessApiDelegate: businessApiDelegate, interruption: interruption, completionHandler: completionHandler)
    }

    public func registerTotp(completion: @escaping (RegisterTotpResult) -> Void ) {
        var params: [String: String] = [:]
        params["regToken"] = self.regToken
        params["provider"] = TFAProvider.totp.rawValue
        params["mode"] = TFAMode.register.rawValue

        businessApiDelegate.sendApi(dataType: InitTFAModel.self, api: GigyaDefinitions.API.initTFA, params: params) { [weak self] result in
            switch result {
            case .success(let data):
                self?.gigyaAssertion = data.gigyaAssertion

                self?.getQrCode(completion: completion)
            case .failure(let error):
                completion(.error(error))
            }
        }
    }

    private func getQrCode(completion: @escaping (RegisterTotpResult) -> Void) {
        var params: [String: String] = [:]
        params["gigyaAssertion"] = self.gigyaAssertion

        businessApiDelegate.sendApi(dataType: TFATotpRegisterModel.self, api: GigyaDefinitions.API.totpRegisterTFA, params: params) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let data):
                guard let sctToken = data.sctToken, let gigyaAssertion = self.gigyaAssertion, let qrCode = data.qrCode, let qrImage = self.makeImageFromQrData(data: qrCode) else {
                    completion(.error(.emptyResponse))
                    return
                }

                self.verifyTotpResolver.setAssertionAndSctToken(gigyaAssertion: gigyaAssertion, sctToken: sctToken)

                completion(.QRCodeAvilabe(image: qrImage, resolver: self.verifyTotpResolver))

            case .failure(let error):
                completion(.error(error))
            }
        }
    }

    private func makeImageFromQrData(data: String) -> UIImage? {
        // make qr image from string
        let split = data.components(separatedBy: ",")

        if split.count > 1, let dataDecoded = Data(base64Encoded: split[1], options: Data.Base64DecodingOptions.ignoreUnknownCharacters),
            let qrImage = UIImage(data: dataDecoded) {
            return qrImage
        }

        return nil
    }
}

@frozen
public enum RegisterTotpResult {
    case QRCodeAvilabe(image: UIImage?, resolver: VerifyTotpResolverProtocol)
    case error(NetworkError)
}


