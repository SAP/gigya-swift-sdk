//
//  LinkAccountScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 21/07/2024.
//

import SwiftUI
import Gigya

struct LinkAccountScreenView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @ObservedObject var viewModel: LinkAccountViewModel

    var body: some View {
        VStack {
            Text("Link Account")
                .bold()
                .font(.system(size: 24))
                .padding(7)
            Text("Use your preferred method")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            
            if let loginProviders =
                viewModel.flowManager.linkAccountResolver?.conflictingAccount?.loginProviders {
                
                ForEach (loginProviders, id: \.hashValue) { provider in
                    Image(provider)
                        .padding(EdgeInsets(top: 30, leading: 5, bottom: 30, trailing: 5))
                        .onTapGesture {
                            viewModel.linkToSocial(provider: provider) {
                                currentCordinator.routing.popToRoot()
                                currentCordinator.parent.isLoggedIn = true
                            }
                        }
                        .accessibilityId(self, "\(provider)Button")
                }
                
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundColor(Color(red: 227/255, green: 227/255, blue: 227/255))
                    .padding(EdgeInsets(top: 5, leading: 75, bottom: 5, trailing: 75))

                
                if loginProviders.contains("site") {
                    CustomInputStyle2(label: "Email:", placeholder: "Email", secured: false, disable: true, value: $viewModel.email)
                        .accessibilityId(self, "emailInput")
                    if viewModel.formIsSubmitState && viewModel.email.isEmpty {
                        Text("Email is empty.")
                            .font(.system(size: 12))
                            .foregroundStyle(.red)
                            .bold()
                    }
                    
                    CustomInputStyle2(label: "Password:", placeholder: "Password", secured: true, value: $viewModel.pass)
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
                    
                    CustomDarkButton(action: {
                        viewModel.linkToSite() {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    }, label: "Login")
                    .accessibilityId(self, "loginButton")
                }
                
            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Link Account"), showIcon: false))

    }
    
}

#Preview {
    LinkAccountScreenView( viewModel: LinkAccountViewModel(gigya: GigyaService(), flowManager: SignInInterruptionFlow()))
}
