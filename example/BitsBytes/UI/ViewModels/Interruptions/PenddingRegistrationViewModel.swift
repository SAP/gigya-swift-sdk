//
//  PenddingRegistrationViewModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 23/07/2024.
//

import Foundation
import Gigya

final class PenddingRegistrationViewModel: BaseViewModel {
    @Published var birthDay: Date = Date.init(timeIntervalSince1970: 0) {
        didSet {
            self.birthDatyIsUpdated = true
        }
    }
    @Published var formIsSubmitState: Bool = false
    @Published var error: String = ""

    var birthDatyIsUpdated: Bool = false
    
    var tempClosure: ()-> Void = { }

    let flowManager: SignInInterruptionFlow

    init(gigya: GigyaService, flowManager: SignInInterruptionFlow) {
        self.flowManager = flowManager
        super.init(gigya: gigya)
    }
    
    func setAccount(clousre: @escaping () -> Void) {
        flowManager.successClousre = { [weak self] in
            self?.toggelLoader()
            clousre()
        }
        
        toggelLoader()
        
        if birthDatyIsUpdated {
            let calendar = Calendar.current
            let year = calendar.component(.year, from: birthDay)
            let month = calendar.component(.month, from: birthDay)
            let day = calendar.component(.day, from: birthDay)
            
            flowManager.penddingRegistrationResolver?.setAccount(params: ["profile":["birthMonth": month, "birthYear": year, "birthDay": day]])
        } else {
            error = "Please choose Birthday"
            toggelLoader()
        }

    }
}
