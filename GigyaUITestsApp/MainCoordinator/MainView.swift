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
        NavigationView {
            VStack(alignment: .trailing) {
                makeButton(title: "Social Login") {

                }

                makeButton(title: "Screenset Login") {

                }

                Spacer()

            }
            .navigationBarTitle(Text("Test Groups"))
        }
    }

    func makeButton(title: String, action: @escaping () -> Void) -> some View {
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
