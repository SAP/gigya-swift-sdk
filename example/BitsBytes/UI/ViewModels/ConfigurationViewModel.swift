//
//  ConfigurationViewModel.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import Foundation

final class ConfigurationViewModel: BaseViewModel {
    @Published var domain: String = ""
    @Published var apiKey: String = ""
    @Published var cname: String = ""

    override init(gigya: GigyaService) {
        super.init(gigya: gigya)
        
        self.domain = gigya.shared.config.apiDomain
        self.apiKey = gigya.shared.config.apiKey ?? ""
        self.cname = gigya.shared.config.cname ?? ""
    }
    
    func reInitGigya() {
        showLoder.toggle()
        gigya?.shared.initFor(apiKey: self.apiKey, apiDomain: self.domain, cname: self.cname)
        showLoder.toggle()
    }

    
}

