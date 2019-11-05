//
//  ThemeUtils.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/11/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import SwiftUI

class ThemeUtils {

    static func makeButton(title: String, action: @escaping () -> Void = {}) -> some View {
        Button(action: action) {
            Text(title)
            .padding()
        }
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Capsule().foregroundColor(.blue))
        .foregroundColor(.white)
        .padding([.leading, .trailing], 20)
        .padding()

    }

    static func socialButton(title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(title)
                .resizable()
                .renderingMode(.original)
                .aspectRatio(contentMode: .fit)
        }

    }
}
