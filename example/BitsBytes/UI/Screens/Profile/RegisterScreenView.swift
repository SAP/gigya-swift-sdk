//
//  RegisterScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 26/02/2024.
//

import SwiftUI

struct RegisterScreenView: View {

    @ObservedObject var viewModel: RegisterViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        VStack {
            VStack {
                Text("Create your account")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                Text("Please fill out the listed inputs")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                
                CustomInputStyle2(label: "First Name:", placeholder: "First Name", secured: false, value: $viewModel.firstName)
                    .accessibilityId(self, "firstNameInput")
                if viewModel.formIsSubmitState && viewModel.firstName.isEmpty {
                    Text("First Name is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                        .accessibilityId(self, "firstNameEmptyError")
                }
                
                CustomInputStyle2(label: "Last Name:", placeholder: "Last Name", secured: false, value: $viewModel.lastName)
                    .accessibilityId(self, "lastNameInput")
                if viewModel.formIsSubmitState && viewModel.lastName.isEmpty {
                    Text("Last Name is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                        .accessibilityId(self, "lastNameEmptyError")
                }
                
                CustomInputStyle2(label: "Email:", placeholder: "Email", secured: false, value: $viewModel.email)
                    .accessibilityId(self, "emailInput")
                if viewModel.formIsSubmitState && viewModel.firstName.isEmpty {
                    Text("Email is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                        .accessibilityId(self, "emailEmptyError")
                }


                CustomInputStyle2(label: "Password:", placeholder: "Password", secured: true, value: $viewModel.pass)
                    .accessibilityId(self, "passInput")
                if viewModel.formIsSubmitState && viewModel.firstName.isEmpty {
                    Text("Password is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                        .accessibilityId(self, "passEmptyError")
                }


                CustomInputStyle2(label: "Confirm Password:", placeholder: "Confirm Password", secured: true, value: $viewModel.confirmPass)
                    .accessibilityId(self, "confirmpassInput")
                if viewModel.formIsSubmitState && viewModel.firstName.isEmpty {
                    Text("Confirm Password is empty.")
                        .font(.system(size: 12))
                        .foregroundStyle(.red)
                        .bold()
                        .accessibilityId(self, "confirmpassEmptyError")
                }


                Text("By clicking on \"register\", you conform that you have read and agree to the privacy policy and terms of use.")
                    .font(.system(size: 14))
                    .padding(EdgeInsets(top: 10, leading: 60, bottom: 0, trailing: 60))
                                
                CustomDarkButton(action: {
                    viewModel.submit() {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = true
                    }
                }, label: "Register")
                .accessibilityId(self, "registerButton")
                                
                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")

                
            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Register").bold()))
    }
}

#Preview {
    NavigationWrapperView(coordinator: Coordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .register))
}
