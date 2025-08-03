//
//  DeviceFlowViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 27/03/2025.
//


import Foundation
import Gigya

final class DeviceFlowViewModel: BaseViewModel {
    @Published var error: String = ""
    
    var account: AccountModel?

    override init(gigya: GigyaService) {
        super.init(gigya: gigya)
    }
    
    func showCamera() {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first
                  as? UIWindowScene)?.windows.first?.rootViewController
              else { return }

        let scannerVc = ScannerViewController()
        scannerVc.closure = { [weak self, weak scannerVc] token in
            scannerVc?.dismiss(animated: true)
        }
        
        presentingViewController.present(scannerVc, animated: true)

    }
    
}
