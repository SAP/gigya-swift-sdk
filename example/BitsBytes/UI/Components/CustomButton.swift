//
//  CustomButton.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import SwiftUI

struct CustomButton: View {
    let action: () -> Void
    let label: String
    let icon: String?
    let padding: Int
    
    init(action: @escaping () -> Void, label: String, icon: String? = nil, padding: Int = 60) {
        self.action = action
        self.label = label
        self.icon = icon
        self.padding = padding
    }

    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if let icon {
                    Image(icon).padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 0))
                    Spacer()
                }
                Text(label)
                    .font(.system(size: 14))
                    .bold()
                    .foregroundStyle(Color(red: 4/255, green: 7/255, blue: 43/255))
                if icon != nil {
                    Spacer()
                }
            }
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 5)
                        .stroke(Color(red: 4/255, green: 7/255, blue: 43/255), lineWidth: 1)
                )                        
                .padding(EdgeInsets(top: 3, leading: CGFloat(padding), bottom: 3, trailing: CGFloat(padding)))

        }
        .tint(.white)
    }
}

struct CustomDarkButton: View {
    let action: () -> Void
    let label: String
    let padding: Int

    init(action: @escaping () -> Void, label: String, padding: Int = 60) {
        self.action = action
        self.label = label
        self.padding = padding
    }
    
    var body: some View {
        Button{
            action()
        } label: {
            Text(label)
                .font(.system(size: 14))
                .bold()
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: 40)
                .background(Color(red: 4/255, green: 7/255, blue: 43/255))
                .buttonStyle(.bordered)
                .cornerRadius(5)
                .padding(EdgeInsets(top: 3, leading: CGFloat(padding), bottom: 3, trailing: CGFloat(padding)))
        }
        .tint(.white)
    }
}


#Preview {
    CustomDarkButton(action: {}, label: "Button")
}


