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
        ZStack {
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 10)
                .background(Color(red: 245/255, green: 246/255, blue: 247/255))
            
            VStack {
                Text("About me")
                    .font(.system(size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                
                CustomInput(label: "First Name", placeholder: "First Name", value: $viewModel.firstName)
                    .accessibilityId(self, "fnameInput")
                CustomInput(label: "Last Name", placeholder: "Last Name", value: $viewModel.lastName)
                    .accessibilityId(self, "lnameInput")
                
                CustomInput(label: "Email", placeholder: "Email", value: $viewModel.email, disable: true)
                    .accessibilityId(self, "emailInput")
                if !viewModel.phone.isEmpty {
                    CustomInput(label: "Phone", placeholder: "Phone", value: $viewModel.phone, disable: true)
                        .accessibilityId(self, "phoneInput")
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
                }, label: "SAVE")
                .accessibilityId(self, "saveButton")
                            
                Spacer(minLength: 5)
                
            }

        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("ABOUT ME"), showIcon: false))
    }
}

#Preview {
    AboutMeScreenView(viewModel: AboutMeViewModel(gigya: GigyaService()))
}
