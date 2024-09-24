//
//  PenddingRegistrationScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 23/07/2024.
//

import SwiftUI

struct PenddingRegistrationScreenView: View {
    @ObservedObject var viewModel: PenddingRegistrationViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        ZStack {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 10)
                .background(Color(red: 245/255, green: 246/255, blue: 247/255))
            
            VStack {
                
                Text("Additional information")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                
                CustomDatePicker(label: "Birthday", placeholder: "Birthday", value: $viewModel.birthDay)
                    .accessibilityId(self, "birthDayInput")
                
                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))
                
                CustomDarkButton(action: {
                    viewModel.setAccount {
                        currentCordinator.routing.popToRoot()
                        currentCordinator.parent.isLoggedIn = true
                    }
                }, label: "SEND")
                .accessibilityId(self, "saveButton")
                            
                Spacer(minLength: 5)
                
            }

        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("Pending Information"), showIcon: false))
    }
}

#Preview {
    PenddingRegistrationScreenView(viewModel: PenddingRegistrationViewModel(gigya: GigyaService(), flowManager: SignInInterruptionFlow()))
}
