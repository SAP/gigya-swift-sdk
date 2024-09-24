//
//  ResetPasswordScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/06/2024.
//

import SwiftUI
import Gigya

struct ResetPasswordScreenView: View {
    @ObservedObject var viewModel: ResetPasswordViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        VStack {
            VStack {
                Text("Reset Password")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                
                Text("Please enter your Email and we will send you an Email with instructions to create a new password")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 60))
                
                
                CustomInputStyle2(label: "Email:", placeholder: "Email", secured: false, value: $viewModel.email)
                    .accessibilityId(self, "emailInput")
//                if viewModel.formIsSubmitState && viewModel.email.isEmpty {
//                    Text("Email is empty.")
//                        .font(.system(size: 12))
//                        .foregroundStyle(.red)
//                        .bold()
//                }

                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
                
                CustomDarkButton(action: {
                    viewModel.send()
//                    viewModel.submit() {
//                        currentCordinator.routing.popToRoot()
//                        currentCordinator.parent.isLoggedIn = true
//                    }
                }, label: "Reset Password")
                    .opacity(viewModel.resetSent ? 0.5 : 1)
                    .disabled(viewModel.resetSent)
                    .accessibilityId(self, "resetButton")

                if viewModel.resetSent == true {
                    Text("The password was sent to you!")
                        .foregroundStyle(Color(red: 0/255, green: 100/255, blue: 216/255))
                        .accessibilityId(self, "passSentLabel")
                }
            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Reset Password").bold()))
    }}

#Preview {
    ResetPasswordScreenView(viewModel: ResetPasswordViewModel(gigya: GigyaService()))
}
