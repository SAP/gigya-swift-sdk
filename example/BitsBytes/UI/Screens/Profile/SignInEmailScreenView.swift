//
//  SignInEmailScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 06/03/2024.
//

import SwiftUI

struct SignInEmailScreenView: View {
    @ObservedObject var viewModel: SignInEmailViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        VStack {
            VStack {
                Text("Sign in with Email")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                Text("Please enter your Email and Password")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                
                CustomInputStyle2(label: "Email:", placeholder: "Email", secured: false, type: .emailAddress, contentType: .emailAddress, value: $viewModel.email)
                    .accessibilityId(self, "emailInput")
                if viewModel.formIsSubmitState && viewModel.email.isEmpty {
                    Text("Email is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                }
                
                CustomInputStyle2(label: "Password:", placeholder: "Password", secured: true, contentType: .password, value: $viewModel.pass)
                    .accessibilityId(self, "passInput")
                if viewModel.formIsSubmitState && viewModel.pass.isEmpty {
                    Text("Password is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                }

                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
                
                if viewModel.flowManager.captchaRequire {
                    Toggle("Captcha:", isOn: $viewModel.captchaSwitch)
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                        .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                        .background(.white)
                        .accessibilityId(self, "captchaToggle")
                }

                Text("Forgot Password?")
                    .bold()
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 12, leading: 140, bottom: 0, trailing: 0))
                    .onTapGesture {
                        viewModel.showPass()
                    }
                
                
                CustomDarkButton(action: {
                    viewModel.submit() {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = true
                    }
                }, label: "Login")
                .accessibilityId(self, "loginButton")
                            
            
            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Sign in").bold()))
        .onAppear {
            viewModel.currentCordinator = currentCordinator
        }
    }
}

#Preview {
    NavigationWrapperView(coordinator: ProfileCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .signinemail))
}

