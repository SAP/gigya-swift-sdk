//
//  MainViewModel.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import SwiftUI
import Combine

class MainViewModel: ObservableObject {

    @Published var socialLoginIsActive: Bool = false

    var socialLoginView: SocialLoginView?

    var gotoSocialLogin: () -> Void = {

    }
    
}
