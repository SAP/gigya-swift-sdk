//
//  ConfigurationScreenView.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import SwiftUI

struct ConfigurationScreenView: View {
    @Environment(AppCoordinator.self) var appCordinator: AppCoordinator

    @ObservedObject var viewModel: ConfigurationViewModel
    
    var body: some View {
        @Bindable var appCordinator = appCordinator
        
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: 10)
            .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        
        VStack {
            Toggle("Use ScreenSets \n(default: native view)", isOn: $appCordinator.webViewMode)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
                .padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
                .background(.white)
                .accessibilityId(self, "screenSetToggle")
            
            CustomInputStyle2(label: "API Key", placeholder: "API Key",secured: false, value: $viewModel.apiKey)
                .accessibilityId(self, "apiInput")
            CustomInputStyle2(label: "Domain", placeholder: "Domain", secured: false,value: $viewModel.domain)
                .accessibilityId(self, "domainInput")
            CustomInputStyle2(label: "CNAME", placeholder: "CNAME",secured: false,  value: $viewModel.cname)
                .accessibilityId(self, "cnameInput")
            
            CustomDarkButton(action: {
                viewModel.reInitGigya()
            }, label: "SAVE")
            .accessibilityId(self, "saveButton")
            
            LoaderView(showSpinner: $viewModel.showLoder)

            Spacer(minLength: 5)

        }
        .background(Color(red: 245/255, green: 246/255, blue: 247/255))
        .modifier(NavBar(Text("APP CONFIGURATION"), showIcon: false))
        
    }
}

#Preview {
    ConfigurationScreenView(viewModel: ConfigurationViewModel(gigya: GigyaService()))
}
