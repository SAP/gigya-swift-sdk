//
//  AboutMeScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 17/04/2024.
//

import SwiftUI

struct AboutMeScreenView: View {
    @ObservedObject var viewModel: AboutMeViewModel

    var body: some View {
        ScrollView {
            VStack {
                Text("About me")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))

                CustomInput(label: "First Name", placeholder: "First Name", accessibilityId: "AboutMeScreenView_fnameInput", value: $viewModel.firstName)
                CustomInput(label: "Last Name", placeholder: "Last Name", accessibilityId: "AboutMeScreenView_lnameInput", value: $viewModel.lastName)

                CustomInput(label: "Email", placeholder: "Email", accessibilityId: "AboutMeScreenView_emailInput", value: $viewModel.email, disable: true)
                if !viewModel.phone.isEmpty {
                    CustomInput(label: "Phone", placeholder: "Phone", accessibilityId: "AboutMeScreenView_phoneInput", value: $viewModel.phone, disable: true)
                }
                Text("Additional information")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))

                CustomDatePicker(label: "Birthday", placeholder: "Birthday", value: $viewModel.birthDay)
                    .accessibilityId(self, "birthDayInput")
                CustomInput(label: "Country", placeholder: "Country", value: $viewModel.country)
                    .accessibilityId(self, "CountryInput")

                Text(viewModel.error)
                    .foregroundStyle(.red)
                    .bold()
                    .accessibilityId(self, "errorLabel")
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 0, trailing: 0))

                CustomDarkButton(action: {
                    viewModel.setAccount()
                }, label: "SAVE", accessibilityId: "AboutMeScreenView_saveButton")

                Spacer(minLength: 5)

            }
        }
        .scrollDismissesKeyboard(.interactively)
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("ABOUT ME"), showIcon: false))
    }
}

#Preview {
    AboutMeScreenView(viewModel: AboutMeViewModel(gigya: GigyaService()))
}
