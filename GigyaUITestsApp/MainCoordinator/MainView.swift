//
//  ContentView.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import SwiftUI

struct MainView: View {
    @ObservedObject var viewModel: MainViewModel

    var body: some View {
        NavigationView {
            VStack {
                NavigationLink(destination: viewModel.socialLoginView!, isActive: self.$viewModel.socialLoginIsActive) {
                    ThemeUtils.makeButton(title: "Social Login") {
                        self.viewModel.gotoSocialLogin()
                    }
                }

                ThemeUtils.makeButton(title: "Screenset Login") {

                }

                Spacer()

            }
            .navigationBarTitle(Text("Test Groups"))
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
