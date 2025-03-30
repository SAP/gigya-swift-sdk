//
//  PorfileScreenView.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import SwiftUI
import Gigya
import SafariServices

struct PorfileScreenView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        if currentCordinator.parent.isLoggedIn {
            LoggedIn()
                .modifier(NavBar(Text("MY PROFILE").bold()))
                .environment(viewModel)
        } else {
            NotLoggedView()
                .modifier(NavBar(Text("SIGN IN").bold()))
                .environment(viewModel)
        }
    }
}

struct LoggedIn: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @Environment(AppCoordinator.self) var appCordinator: AppCoordinator

    @Environment(ProfileViewModel.self) var viewModel: ProfileViewModel

    @State private var isPresentWebView = false

    var body: some View {
        ScrollView {
            ZStack {
                Spacer()
                    .frame(maxWidth: .infinity, maxHeight: 85)
                    .background(
                        LinearGradient(gradient: Gradient(colors: [Color(red: 245/255, green: 126/255, blue: 164/255), Color(red: 124/255, green: 90/255, blue: 208/255), Color(red: 103/255, green: 100/255, blue: 225/255)]), startPoint: .top, endPoint: .bottom)
                    )
                AsyncImage(url: URL(string: viewModel.image)) { phase in
                     if let image = phase.image {
                         image
                             .resizable()
                             .scaledToFill()
                             .background(.white)
                             .border(.white, width: 2)
                             .frame(width: 100, height: 100)
                             .clipShape(Circle())
                             .offset(y: 40)
                     } else if phase.error != nil {
                         ZStack {
                             Rectangle()
                                 .fill(Color(red: 223/255, green: 227/255, blue: 231/255))
                                 .clipShape(Circle())
                             Text(viewModel.name.prefix(1))
                                 .foregroundColor(.white)
                                 .font(.system(size: 50))
                                 .bold()
                         }
                         .frame(width: 100, height: 100)
                         .offset(y: 40)
                     } else {
                         // Acts as a placeholder.
                         ZStack {
                             Rectangle()
                                 .fill(Color(red: 223/255, green: 227/255, blue: 231/255))
                                 .clipShape(Circle())
                             Text(viewModel.name.prefix(0))
                                 .foregroundColor(.white)
                                 .font(.system(size: 50))
                                 .bold()
                         }
                         .frame(width: 100, height: 100)
                         .offset(y: 40)
       


                     }
                 }

            }
            .frame(maxWidth: .infinity, minHeight: 170, alignment: .top)
            .background(.white)
            
            VStack {
                Text("Welcome")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                Text(viewModel.name)
                    .foregroundStyle(.black)
                    .font(.system(size: 36))
            }
            .frame(maxWidth: .infinity, minHeight: 100)
            .background(.white)
            .padding(EdgeInsets(top: -10, leading: 0, bottom: 0, trailing: 0))
            
            VStack(spacing: 0) {
                CustomRow(label: "About Me", icon: "aboutme", showRightIcon: true) {
                    if appCordinator.webViewMode {
                        viewModel.loginWebView(screen: .profile) {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    } else {
                        currentCordinator.routing.push(.aboutme)
                    }
                }
                    .padding(.zero)
                CustomRow(label: "Change Password", icon: "changepassword", showRightIcon: true) {
                    
                    if appCordinator.webViewMode {
                        viewModel.loginWebView(screen: .profile, startScreen: .changePassword) {
                            currentCordinator.routing.popToRoot()
                            currentCordinator.parent.isLoggedIn = true
                        }
                    } else {
                        currentCordinator.routing.push(.changePass)
                    }
                }
                Spacer()
                CustomRow(label: "Login Options", icon: "passwordless", showRightIcon: false) {
                    currentCordinator.routing.push(.passwordless)
                }
                Spacer()
                CustomRow(label: "Add Phone", icon: "phone", showRightIcon: false) {
                    currentCordinator.routing.flowManager?.otpCurrentMode = .update
                    currentCordinator.routing.push(.addPhone)
                }
                Spacer()
                CustomRow(label: "Exchange Token", icon: "exchangeToken", showRightIcon: false) {
                    Task {
                        await viewModel.getAuthcode()
                    }
                    

                }
                Spacer()
                CustomRow(label: "Logout", icon: "logout", showRightIcon: false) {
                    viewModel.logout {
                        currentCordinator.parent.isLoggedIn = false
                    }
                }
                .accessibilityId(self, "logoutButton")

            }
            
        }
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
    }
}

struct NotLoggedView: View {
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator
    @Environment(AppCoordinator.self) var appCordinator: AppCoordinator
    
    @Environment(ProfileViewModel.self) var viewModel: ProfileViewModel

    var body: some View {
        VStack {
            Text("Welcome!")
                .bold()
                .font(.system(size: 32))
            Text("Manage your profile")
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            
            CustomButton(action: {
                if appCordinator.webViewMode {
                    viewModel.loginWebView(screen: .login) {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = true
                    }
                } else {
                    currentCordinator.routing.push(.signin)
                }
            }, label: "Sign in")
            .accessibilityIdentifier("Profile_signinButton")
            
            CustomDarkButton(action: {
                if appCordinator.webViewMode {
                    viewModel.loginWebView(screen: .login, startScreen: .register) {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = true
                    }
                } else {
                    currentCordinator.routing.push(.register)
                }
            }, label: "Register")
            .accessibilityIdentifier("Profile_registerButton")
            
            CustomDarkButton(action: {
                currentCordinator.routing.push(.deviceFlow)
            }, label: "Device Flow")
            .accessibilityIdentifier("Profile_deviceFlowButton")

        }
    }
}

#Preview {
    Group {
        let currentCordinator: ProfileCoordinator = ProfileCoordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .profile)
        
        let viewModel: ProfileViewModel = ProfileViewModel(gigya: GigyaService())

        LoggedIn()
            .environment(currentCordinator)
            .environment(viewModel)
    }
}
