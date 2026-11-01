//
//  SignInIdentifierScreenView.swift
//  BitsBytes
//
//  Created by Assistant on [DATE].
//

import SwiftUI

struct SignInIdentifierScreenView: View {
    @ObservedObject var viewModel: SignInIdentifierViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        VStack {
            VStack {
                Text("Sign in with Custom Identifier")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                Text("Please enter your Custom Identifier and Password")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                
                CustomInputStyle2(label: "Identifier:", placeholder: "Identifier", secured: false, type: .default, contentType: .username, value: $viewModel.identifier)
                    .accessibilityId(self, "identifierInput")
                if viewModel.formIsSubmitState && viewModel.identifier.isEmpty {
                    Text("Identifier is empty.")
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
    NavigationWrapperView(coordinator: ProfileCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .signinidentifier))
}
