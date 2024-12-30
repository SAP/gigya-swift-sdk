//
//  RoutingCoordinator.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import Foundation
import SwiftUI
import Observation

@Observable
class RoutingManager {
    var screens = NavigationPath()
    let gigya = GigyaService()
    
    var flowManager: SignInInterruptionFlow? = SignInInterruptionFlow()
    
    @ViewBuilder
    func navigate(to screen: Screens) -> some View {
        switch screen {
        case .home:
            HomeScreenView()
        case .configuration:
            let configurationViewModel = ConfigurationViewModel(gigya: gigya)
            ConfigurationScreenView(viewModel: configurationViewModel)
        case .profile:
            let profileViewModel = ProfileViewModel(gigya: gigya)
            PorfileScreenView(viewModel: profileViewModel)
        case .signin:
            let signinViewModel = SignInViewModel(gigya: gigya, flowManager: flowManager!)
            SignInScreenView(viewModel: signinViewModel)
        case .register:
            let registerViewModel = RegisterViewModel(gigya: gigya, flowManager: flowManager!)
            RegisterScreenView(viewModel: registerViewModel)
        case .signinemail:
            let signInEmailrViewModel = SignInEmailViewModel(gigya: gigya, flowManager: flowManager!)
            SignInEmailScreenView(viewModel: signInEmailrViewModel)
        case .aboutme:
            let aboutmeViewModel = AboutMeViewModel(gigya: gigya)
            AboutMeScreenView(viewModel: aboutmeViewModel)
        case .passwordless:
            let passwordlessViewModel = PasswordlessViewModel(gigya: gigya)
            PasswordlessScreenView(viewModel: passwordlessViewModel)
        case .otpLogin:
            let otpViewModel = OtpViewModel(gigya: gigya, flowManager: flowManager!)
            OtpScreenView(viewModel: otpViewModel)
        case .changePass:
            let changePassViewModel = ChangePasswordViewModel(gigya: gigya)
            ChangePasswordScreenView(viewModel: changePassViewModel)
        case .resetPassword:
            let resetPassViewModel = ResetPasswordViewModel(gigya: gigya)
            ResetPasswordScreenView(viewModel: resetPassViewModel)

        case .linkAccount:
            let linkViewModel = LinkAccountViewModel(gigya: gigya, flowManager: flowManager!)
            LinkAccountScreenView(viewModel: linkViewModel)
        case .penddingRegistration:
            let penddingViewModel = PenddingRegistrationViewModel(gigya: gigya, flowManager: flowManager!)
            PenddingRegistrationScreenView(viewModel: penddingViewModel)
        case .addPhone :
            let otpViewModel = OtpViewModel(gigya: gigya, flowManager: flowManager!)
            AddPhoneScreenView(viewModel: otpViewModel)
        case .tfaMethods:
            let tfaViewModel = TfaMethodsViewModel(gigya: gigya, flowManager: flowManager!)
            TfaMethodsScreenView(viewModel: tfaViewModel)

        default:
            HomeScreenView()
        }
    }
    
    // add screen
    func push(_ screen: Screens) {
        screens.append(screen)
    }
    
    // remove last screen
    func pop() {
        screens.removeLast()
    }
    
    // go to root screen
    func popToRoot() {
        screens.removeLast(screens.count)
    }
}

