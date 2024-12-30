//
//  AuthMethodsScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 16/12/2024.
//

import SwiftUI
import Gigya

struct TfaMethodsScreenView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    @ObservedObject var viewModel: TfaMethodsViewModel

    var body: some View {

        ZStack {
            switch viewModel.state {
            case .none:
            
            VStack(spacing: 0) {
                Text("Auth Methods")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                Text("Use your preferred method")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundColor(Color(red: 227/255, green: 227/255, blue: 227/255))
                    .padding(EdgeInsets(top: 5, leading: 75, bottom: 5, trailing: 75))
                
                  
                ForEach ( viewModel.flowManager.tfaAvailableProviders, id: \.self) { provider in

                    if provider.name == TFAProvider.email {
                        CustomButton(action: {
                            viewModel.state = .email
                        }, label: "Use a Email", icon: "email")
                        .accessibilityId(self, "emailButton")

                    }
                    else if provider.name == TFAProvider.phone {
                        CustomButton(action: {
                            viewModel.state = .phone
                            viewModel.getPhones()
                        }, label: "Use a Phone", icon: "phone")
                        .accessibilityId(self, "phoneButton")

                    }
                    else if provider.name == TFAProvider.totp {
                        CustomButton(action: {
                            viewModel.state = .totp
                            viewModel.getTotp()
                        }, label: "Use a TOTP App", icon: "passwordless")
                        .accessibilityId(self, "passwordlessButton")

                    }
                }
            }

            case .phone:
                PhoneTfaMethodsScreenView()
            case .totp:
                TotpTfaMethodsScreenView(viewModel: viewModel)
            case .email:
                TotpTfaMethodsScreenView(viewModel: viewModel)
            }

        }
//        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Auth Methods").bold()))
        .environment(viewModel)
    }
}

struct TotpTfaMethodsScreenView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @ObservedObject var viewModel: TfaMethodsViewModel

    
    var body: some View {
        VStack(spacing: 0) {

            if viewModel.qrImage != nil {
                Text("Use an authenticator app (such as Google Authenticator) to scan this QR code or manually enter the secret key. ")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .padding(20)
            }

            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundColor(Color(red: 227/255, green: 227/255, blue: 227/255))
                .padding(EdgeInsets(top: 5, leading: 75, bottom: 5, trailing: 75))
            
            if let qrImage = viewModel.qrImage {
                Image(uiImage: qrImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(30)
            }
            
            Text("Enter the 6-Digit Code")
                .bold()
                .font(.system(size: 24))
                .padding(7)
            Text("Enter the code from your authenticator app")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            CustomInputStyle2(label: "Enter Verification Code:", placeholder: "", secured: false, value: $viewModel.code)
                .accessibilityId(self, "codeInput")
            
            CustomDarkButton(action: {
                viewModel.verifyCode()
            }, label: "Verify")
            


        }
        .padding(10)
    }
    
}


struct PhoneTfaMethodsScreenView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @Environment(TfaMethodsViewModel.self) var viewModel: TfaMethodsViewModel

    var body: some View {
        VStack(spacing: 0) {
            Text("Phone Verification")
                .bold()
                .font(.system(size: 24))
                .padding(7)
            Text("Select your phone number")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            
            Rectangle()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .foregroundColor(Color(red: 227/255, green: 227/255, blue: 227/255))
                .padding(EdgeInsets(top: 5, leading: 75, bottom: 5, trailing: 75))
            
            ForEach ( viewModel.registredPhones, id: \.self) { provider in
                CustomButton(action: {
                    viewModel.flowManager.selectedPhone = provider
                    currentCordinator.routing.push(.otpLogin)
                }, label: provider.obfuscated ?? "", icon: "phone")
                .accessibilityId(self, "phoneButton")
            }
        }
    }
    
}

#Preview {
//    TfaMethodsScreenView()
}
