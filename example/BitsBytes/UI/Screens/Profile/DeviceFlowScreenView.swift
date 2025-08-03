//
//  DeviceFlowScreenView.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 27/03/2025.
//
import SwiftUI
import Gigya

struct DeviceFlowScreenView: View {
    @ObservedObject var viewModel: DeviceFlowViewModel
    @Environment(ProfileCoordinator.self) var currentCordinator: ProfileCoordinator

    var body: some View {
        VStack {
            VStack {
                Text("Device Flow")
                    .bold()
                    .font(.system(size: 24))
                    .padding(7)
                
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 0, leading: 60, bottom: 0, trailing: 60))
                
                CustomDarkButton(action: {
                    viewModel.showCamera()
                }, label: "Scan QR")
                    .accessibilityId(self, "scanButton")

            }
        }
        .modifier(LoaderModifier(showSpinner: $viewModel.showLoder))
        .modifier(NavBar(Text("Device Flow").bold()))
    }}

#Preview {
    DeviceFlowScreenView(viewModel: DeviceFlowViewModel(gigya: GigyaService()))
}
