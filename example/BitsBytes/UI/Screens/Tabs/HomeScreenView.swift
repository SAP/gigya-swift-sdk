//
//  HomeScreenView.swift
//  
//
//  Created by Sagi Shmuel on 05/02/2024.
//

import SwiftUI

struct HomeScreenView: View {
//    @Environment(HomeCoordinator.self) var currentCordinator: HomeCoordinator
    
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                    .padding(.all)
                Text("The All-new")
                    .foregroundStyle(.gray)
                    .font(.system(size: 24))
                Text("MacBook Pro")
                    .bold()
                    .font(.system(size: 32))
                Text("with Retina display")
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 29/255, green: 45/255, blue: 62/255))
                
                CustomButton(action: {
                    
                }, label: "Buy Now")
                
                Image("homePhoto")
                    .padding(.top)
            }
            VStack {
                Text("All New")
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
                Text("2024")
                    .font(.system(size: 14))
                    .foregroundStyle(.white)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ZStack {
                            VStack {
                                Image("headphone").padding(.all)
                                Text("Headphones")
                                    .padding([.bottom])
                            }
                        }
                        .padding(.all)
                        .frame(width: 140, height: 230)
                        .background(.white)
                        .cornerRadius(8)
                        
                        ZStack {
                            VStack {
                                Image("mac").padding(.all)
                                Text("MacBook")
                                    .padding([.bottom])
                            }
                        }
                        .padding(.all)
                        .frame(width: 140, height: 230)
                        .background(.white)
                        .cornerRadius(8)
                        
                        ZStack {
                            VStack {
                                Image("headphone").padding(.all)
                                Text("iPhone")
                                    .padding([.bottom])
                            }
                        }
                        .padding(.all)
                        .frame(width: 140, height: 230)
                        .background(.white)
                        .cornerRadius(8)
                        

                    }
                }.padding([.top, .leading, .bottom])
                CustomButton(action: {
                    
                }, label: "More")
                .padding(.bottom)
                
            }
            
            .frame(maxWidth: .infinity, minHeight:450, maxHeight: 450)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(red: 124/255, green: 90/255, blue: 208/255, opacity: 0.85), Color(red: 136/255, green: 246/255, blue: 250/255, opacity: 0.63)]), startPoint: .top, endPoint: .bottom))
            .padding(.top)
        }
        .modifier(NavBar(Image("logo")))

    }
    
}

#Preview {
    NavigationWrapperView(coordinator: Coordinator(parent: AppCoordinator(), routing: RoutingManager(), id: .home))
}
