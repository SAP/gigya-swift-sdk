//
//  MainCoordinator.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import Combine
import SwiftUI

class MainCoordinator: Coordinator {

    @ObservedObject var mainViewModel: MainViewModel

    lazy var socialLoginView: SocialLoginView = {
        let socialLoginViewModel = SocialLoginViewModel()
        let socialLoginView = SocialLoginView(viewModel: socialLoginViewModel)
        return socialLoginView
    }()

    init() {
        self.mainViewModel = MainViewModel()
    }

    func start() {
        mainViewModel.socialLoginView = socialLoginView

        mainViewModel.gotoSocialLogin = {
            self.mainViewModel.socialLoginIsActive = true
        }
    }

    func getView() -> UIHostingController<MainView> {
        let contentView = MainView(viewModel: mainViewModel)
        let hostingController = UIHostingController(rootView: contentView)

        return hostingController

    }
}
