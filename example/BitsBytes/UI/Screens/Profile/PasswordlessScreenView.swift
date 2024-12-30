//
//  PasswordlessScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 26/05/2024.
//

import SwiftUI

struct PasswordlessScreenView: View {
    @ObservedObject var viewModel: PasswordlessViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: 10)
            .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        
        VStack(spacing: 0) {
            CustomRowWithButton(label: "Passkey Login", active: $viewModel.fidoIsAvailable) {
                viewModel.useFido()
            }
            .accessibilityId(self, "passwordless")
            
            CustomRowWithButton(label: "Push 2-Factor Authentication", active: .constant(false)) {
                viewModel.pushTfaAction()
            }
            .accessibilityId(self, "push")

            CustomRowWithButton(label: "Biometrics", active: $viewModel.biometricAvailable) {
                viewModel.biometricAction()
            }
            .accessibilityId(self, "biometrics")

            if viewModel.biometricAvailable {
                CustomDarkButton(action: {
                    viewModel.lockSession {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = false
                    }
                }, label: "Locked Session")
            }
            
            Text(viewModel.error)
                .foregroundStyle(.red)
                .bold()
                .padding(10)
                .accessibilityId(self, "errorLabel")
            
            Text(viewModel.msg)
                .foregroundStyle(.green)
                .bold()
                .padding(10)
                .accessibilityId(self, "msgLabel")

            Spacer(minLength: 5)

        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("LOGIN OPTIONS"), showIcon: false))
        
    }
}

#Preview {
    PasswordlessScreenView(viewModel: PasswordlessViewModel(gigya: GigyaService()))
}
