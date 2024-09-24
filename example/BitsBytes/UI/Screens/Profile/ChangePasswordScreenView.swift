//
//  ChangePasswordScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/06/2024.
//

import SwiftUI

struct ChangePasswordScreenView: View {
    
    @ObservedObject var viewModel: ChangePasswordViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    
    var body: some View {
        ZStack {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 10)
                .background(Color(red: 245/255, green: 246/255, blue: 247/255))
            
            VStack {
                
                CustomInput(label: "Current Password", placeholder: "Enter your current password", secured: true, value: $viewModel.currentPass)
                    .accessibilityId(self, "currentPassInput")
                
                CustomInput(label: "New Password", placeholder: "Enter new password", secured: true, value: $viewModel.newPass)
                    .accessibilityId(self, "newPassInput")
                
                CustomInput(label: "Confirm New Password", placeholder: "Enter new password", secured: true, value: $viewModel.confirmPass)
                    .accessibilityId(self, "confirmPassInput")
                
                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                
                CustomDarkButton(action: {
                    viewModel.savePassword {
                        currentCordinator.routing.pop()
                    }
                }, label: "Save Password")
                .accessibilityId(self, "saveButton")
                
                Spacer(minLength: 5)
                
            }
            
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("Change Password"), showIcon: false))
    }
}

#Preview {
    ChangePasswordScreenView(viewModel: ChangePasswordViewModel(gigya: GigyaService()))
}
