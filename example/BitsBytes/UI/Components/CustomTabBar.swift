//
//  CustomTabBar.swift
//  
//
//  Created by Sagi Shmuel on 23/01/2024.
//

import Foundation
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Screens
    
    var body: some View {
        VStack {
            HStack {
                ForEach(Screens.onlyTabs(), id: \.rawValue) { tab in
                    Spacer()
                    Image(tab.rawValue)
                        .colorMultiply(tab == selectedTab ? .white : .gray)
                        .opacity(tab == selectedTab ? 1 : 0.4)
                        .scaleEffect(tab == selectedTab ? 1.25 : 1)
                        .accessibilityIdentifier("\(tab.rawValue)TabButton")
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedTab = tab
                            }
                        }
                    Spacer()
                }
            }
            .frame(width: nil, height: 60)
            .padding(.leading)
            .padding(.trailing)
            .background(.white)
            .cornerRadius(10)
            
            Spacer()
                .frame(maxWidth: .infinity, maxHeight: 10)
                .background(.white)
        }
    }
    
}

#Preview {
    CustomTabBar(selectedTab: .constant(.home))
}

