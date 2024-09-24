//
//  SplashScreenView.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import SwiftUI

struct SplashScreenView: View {
    @Binding var isActive: Bool
    
    var body: some View {
        Image("splash")
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            withAnimation {
                                self.isActive = true
                            }
                        }
                    }
    }
}

#Preview {
    SplashScreenView(isActive: .constant(true))
}
