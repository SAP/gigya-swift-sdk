//
//  SignInScreenView.swift
//  
//
//  Created by Sagi Shmuel on 12/02/2024.
//

import SwiftUI

struct SignInScreenView: View {
    @ObservedObject var viewModel: SignInViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
        
    var body: some View {

        ZStack {
            VStack(spacing: 0) {
                Text("Sign In")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                Text("Use your preferred method")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                
                HStack {
                    Image("line")
                        .padding(EdgeInsets(top: 30, leading: 5, bottom: 30, trailing: 5))
                        .onTapGesture {
                            viewModel.loginWithProvider(.line) {
                                currentCordinator.routing.popToRoot()
                                currentCordinator.parent.isLoggedIn = true
                            }
                        }
                        .accessibilityId(self, "lineButton")
                    Image("facebook")
                        .padding(EdgeInsets(top: 30, leading: 5, bottom: 30, trailing: 5))
                        .onTapGesture {
                            viewModel.loginWithProvider(.facebook) {
                                currentCordinator.routing.popToRoot()
                                currentCordinator.parent.isLoggedIn = true
                            }
                        }
                        .accessibilityId(self, "facebookButton")
                    Image("google")
                        .padding(EdgeInsets(top: 30, leading: 5, bottom: 30, trailing: 5))
                        .onTapGesture {
                            viewModel.loginWithProvider(.google) {
                                currentCordinator.routing.popToRoot()
                                currentCordinator.parent.isLoggedIn = true
                            }
                        }
                        .accessibilityId(self, "googleButton")
                    Image("apple")
                        .padding(EdgeInsets(top: 30, leading: 5, bottom: 30, trailing: 5))
                        .onTapGesture {
                            viewModel.loginWithProvider(.apple) {
                                currentCordinator.routing.popToRoot()
                                currentCordinator.parent.isLoggedIn = true
                            }
                        }
                        .accessibilityId(self, "appleButton")

                }
                Rectangle()
                    .frame(maxWidth: .infinity, maxHeight: 1)
                    .foregroundColor(Color(red: 227/255, green: 227/255, blue: 227/255))
                    .padding(EdgeInsets(top: 5, leading: 75, bottom: 5, trailing: 75))
                CustomButton(action: {
                    Task {
                        let success = await viewModel.fidoLogin()
                        if success {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    }
                }, label: "Sign in with Passkey", icon: "passwordless")
                .accessibilityId(self, "passwordlessButton")
                
                CustomButton(action: {
                    currentCordinator.routing.push(.signinemail)
                }, label: "Sign in with Email", icon: "email")
                .accessibilityId(self, "emailButton")
                
                CustomButton(action: {
                    currentCordinator.routing.push(.otpLogin)
                }, label: "Sign in with Phone", icon: "phone")
                .accessibilityId(self, "phoneButton")
                
                if viewModel.biometricAvailable {
                    CustomDarkButton(action: {
                        viewModel.unlockSession {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    }, label: "Biometric Unlock")
                    .accessibilityIdentifier("Profile_biometricButton")
                }

            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Sign In").bold()))
    }
}

#Preview {
    NavigationWrapperView(coordinator: ProfileCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .signin))
}
