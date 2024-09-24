//
//  CustomInput.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import SwiftUI

struct CustomInput: View {
    
    let label: String
    let placeholder: String
    var secured: Bool = false
    
    @Binding var value: String
    @State var disable = false
    @State var lineColor = Color(red: 217/255, green: 217/255, blue: 217/255)
    
    var body: some View {
        VStack {
            VStack {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                if secured {
                    SecureField("", text: $value)
                        .disabled(disable)
                        .bold()
                        .placeholder(when: value.isEmpty) {
                            Text(placeholder).foregroundColor(.gray).accessibilityHidden(true)
                        }
                        .accessibilityIdentifier("SecureField")

                } else {
                    TextField("", text: $value, onEditingChanged: { state in
                        if state {
                            lineColor = .black
                        } else {
                            lineColor = Color(red: 217/255, green: 217/255, blue: 217/255)
                        }
                    })
                    .disabled(disable)
                    .bold()
                    .placeholder(when: value.isEmpty) {
                        Text(placeholder).foregroundColor(.gray).accessibilityHidden(true)
                    }
                    .accessibilityIdentifier("TextField")

                }
            }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
        }.background(.white)
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(lineColor)
    }
}

struct CustomInputStyle2: View {
    let label: String
    let placeholder: String
    let secured: Bool
    var type: UIKeyboardType = .default
    var contentType: UITextContentType? = .none
    @State var disable = false
    @Binding var value: String

    
    var body: some View {
        VStack {
            Text(label)
                .font(.system(size: 14))
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.gray)
            
            if secured  {
                SecureField(placeholder, text: $value)
                    .textFieldStyle(.roundedBorder)
                    .border(width: 0.6, edges: [.bottom], color: .gray)
            } else {
                TextField(placeholder, text: $value)
                    .keyboardType(type)
                    .textContentType(contentType)
                    .disabled(disable)
                    .textFieldStyle(.roundedBorder)
                    .border(width: 0.6, edges: [.bottom], color: .gray)
            }

//                .shadow(color: .gray, radius: 1, x: 0, y: 1)

            
        }
        .padding(EdgeInsets(top: 10, leading: 60, bottom: 0, trailing: 60))
    }
}

struct CustomDatePicker: View {
    
    let label: String
    let placeholder: String
    
    @Binding var value: Date
    @State var disable = false
    @State var lineColor = Color(red: 217/255, green: 217/255, blue: 217/255)
    
    var body: some View {
        VStack {
            VStack {
                Text(label)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
                HStack {
                    DatePicker(selection: $value, in: ...Date.now, displayedComponents: .date) {
                    }
                        .labelsHidden()
                        .clipped()
                        .fixedSize()
                        .disabled(disable)
                        .bold()
                        .accessibilityIdentifier("DatePicker")
                    Spacer()
                }
            }.padding(EdgeInsets(top: 10, leading: 30, bottom: 10, trailing: 30))
        }.background(.white)
        Spacer()
            .frame(maxWidth: .infinity, maxHeight: 1)
            .background(lineColor)
    }
}

#Preview {
    CustomDatePicker(label: "Test", placeholder: "test", value: .constant(Date.now))
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content) -> some View {

        ZStack(alignment: alignment) {
            placeholder().opacity(shouldShow ? 1 : 0)
            self
        }
    }
}


struct EdgeBorder: Shape {
    var width: CGFloat
    var edges: [Edge]

    func path(in rect: CGRect) -> Path {
        edges.map { edge -> Path in
            switch edge {
            case .top: return Path(.init(x: rect.minX, y: rect.minY, width: rect.width, height: width))
            case .bottom: return Path(.init(x: rect.minX+3, y: rect.maxY - width, width: rect.width-5, height: width))
            case .leading: return Path(.init(x: rect.minX, y: rect.minY, width: width, height: rect.height))
            case .trailing: return Path(.init(x: rect.maxX - width, y: rect.minY, width: width, height: rect.height))
            }
        }.reduce(into: Path()) { $0.addPath($1) }
    }
}

extension View {
    func border(width: CGFloat, edges: [Edge], color: Color) -> some View {
        overlay(EdgeBorder(width: width, edges: edges).foregroundColor(color))
    }
}

