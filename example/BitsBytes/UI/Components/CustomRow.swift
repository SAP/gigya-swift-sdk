//
//  CustomRow.swift
//  BitsBytes
//
//  Created by Sagi Shmuel on 03/03/2024.
//

import SwiftUI

struct CustomRow: View {
    let label: String
    let icon: String
    let showRightIcon: Bool
    let closure: ()-> Void
    
    var body: some View {
        HStack {
            Image(icon)
                .frame(maxWidth: 30, alignment: .leading)
            Text(label)
                .frame(maxWidth: .infinity, minHeight: 30, alignment: .leading)
            if showRightIcon {
                Image(systemName: "chevron.compact.right")
                    .frame(minWidth: 30, alignment: .trailing)
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .frame(maxWidth: .infinity, minHeight: 50, alignment: .center)
        .background(.white)
        .border(width: 1, edges: [.bottom], color: Color(red: 217/255, green: 217/255, blue: 217/255))
        .onTapGesture {
            closure()
        }
    }
}

struct CustomRowWithButton: View {
    let label: String
    @Binding var active: Bool
    let closure: ()-> Void
    
    var body: some View {
        HStack {
            Text(label)

            Spacer()
            if active {
                CustomDarkButton(action: {
                    closure()
                }, label: "Deactivate", padding: 0)
                .frame(width: 130, alignment: .trailing)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 15))

            } else {
                CustomButton(action: {
                    closure()
                }, label: "Activate", padding: 0)
                .frame(width: 130, alignment: .trailing)
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 15))
            }
        }
        .padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 0))
        .frame(maxWidth: .infinity, minHeight: 60)
        .background(.white)
        .border(width: 1, edges: [.bottom], color: Color(red: 217/255, green: 217/255, blue: 217/255))
    }
}

#Preview {
    CustomRowWithButton(label: "Passwordless login", active:  .constant(true) , closure: {})
}
