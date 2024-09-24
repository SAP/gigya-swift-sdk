//
//  LoaderView.swift
//  
//
//  Created by Sagi Shmuel on 06/02/2024.
//

import SwiftUI

struct LoaderView: View {
    @Binding var showSpinner: Bool
    @State var start: Bool = false
    @State private var degree: Int = 270
    @State private var spinnerLength = 0.6

    var body: some View {
        
        if showSpinner {
            VStack {
                Circle()
                    .trim(from: 0.0,to: spinnerLength)
                    .stroke(LinearGradient(colors: [.red,.blue], startPoint: .topLeading, endPoint: .bottomTrailing),style: StrokeStyle(lineWidth: 8.0,lineCap: .round,lineJoin:.round))
                    .animation(.easeIn(duration: 1.5).repeatForever(autoreverses: true), value: start)
                    .frame(width: 60,height: 60)
                    .rotationEffect(Angle(degrees: Double(degree)))
                    .animation(.linear(duration: 1).repeatForever(autoreverses: false), value: start)
                    .onAppear {
                        degree = 270 + 360
                        spinnerLength = 0
                        start = true
                    }
                    .onDisappear {
                        degree = 270
                        spinnerLength = 0.6
                        start = false

                    }
            }
        }

    }

}

struct LoaderModifier: ViewModifier {
    @Binding var showSpinner: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
            LoaderView(showSpinner: $showSpinner)
        }
    }
}


class LoaderExtendModel {
    @Published var showLoder: Bool = false

    func toggelLoader() {
        Task { @MainActor in
            self.showLoder.toggle()
        }
    }
}

//#Preview {
//    LoaderView(showSpinner: .constant(true))
//}
