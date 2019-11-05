//
//  SocialLogin.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import SwiftUI
import Gigya

struct SocialLoginView: View {
    let gigya = Gigya.sharedInstance()

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    ForEach(GigyaNativeSocialProviders.allCases, id: \.self) { (provider) in
                            ThemeUtils.socialButton(title: provider.rawValue) {

                            }
                        }
                }
                Spacer()
            }
            .navigationBarTitle("Choose Social Provider")
            .padding()
        }
    }
}

struct SocialLoginView_Previews: PreviewProvider {
    static var previews: some View {
        SocialLoginView()
    }
}
