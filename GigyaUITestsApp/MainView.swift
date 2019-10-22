//
//  ContentView.swift
//  GigyaUITestsApp
//
//  Created by Shmuel, Sagi on 03/10/2019.
//  Copyright © 2019 Gigya. All rights reserved.
//

import SwiftUI

struct MainView: View {
    var body: some View {
        ZStack {
            Color(UIColor.darkGray).edgesIgnoringSafeArea(.all)
            Button(action: {

            }) {
                Text("Test")
                .padding()
            }
            .background(Capsule().foregroundColor(.blue))
            .foregroundColor(.white)
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
