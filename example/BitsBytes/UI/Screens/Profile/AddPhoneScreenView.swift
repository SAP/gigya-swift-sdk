//
//  AddPhoneScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 20/08/2024.
//

import SwiftUI

struct AddPhoneScreenView: View {
    @ObservedObject var viewModel: OtpViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    
    var body: some View {
        
        ZStack {
            VStack {
                Text("Add Phone Number")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                
                if viewModel.codeSent == false {
                    Text("Please enter your phone number")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    CustomInputStyle2(label: "Phone Number:", placeholder: "Phone", secured: false, value: $viewModel.phone)
                        .accessibilityId(self, "PhoneInput")
                    
                    CustomDarkButton(action: {
                        viewModel.sendCode {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    }, label: "Send Code")
                    
                } else {
                    CustomInputStyle2(label: "Enter Verification Code:", placeholder: "", secured: false, value: $viewModel.code)
                        .accessibilityId(self, "PhoneInput")
                    
                    CustomDarkButton(action: {
                        viewModel.verifyCode()
                    }, label: "Verify")
                    
                    Text("Didn't get code?")
                        .font(.system(size: 14))
                }
                
                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
            }
            


        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))

        .modifier(NavBar(Text("Sign In").bold()))
    }
}

//#Preview {
//    AddPhoneScreenView()
//}
