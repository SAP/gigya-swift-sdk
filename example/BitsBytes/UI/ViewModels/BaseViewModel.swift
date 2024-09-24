//
//  BaseVideModel.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/06/2024.
//

import Foundation

class BaseViewModel: LoaderExtendModel , ObservableObject {
    let gigya: GigyaService?
    
    init(gigya: GigyaService) {
        self.gigya = gigya
    }
}
