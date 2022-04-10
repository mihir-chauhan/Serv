//
//  AccountSignUpView.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/9/22.
//

import SwiftUI

struct AccountSignUpView: View {
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    @State var confirmPassword: String = ""
    var body: some View {
        VStack {
            HStack (alignment: .center, spacing: 10) {
                Image(systemName: "person.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.mint.opacity(0.5))
                
                TextField("Name", text: $usernameEntered)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            .padding(.bottom, 40)
        HStack (alignment: .center, spacing: 10) {
            Image(systemName: "person.fill")
                .resizable()
                .frame(width: 25, height: 25)
                .aspectRatio(contentMode: .fit)
                .foregroundColor(Color.mint.opacity(0.5))
            
            TextField("Username", text: $usernameEntered)
        }
        .padding(10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
        .padding(.bottom, 40)
            VStack {
                HStack (alignment: .center, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.mint.opacity(0.5))
                    
                    SecureField("Password", text: $passwordEntered)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
                HStack (alignment: .center, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.mint.opacity(0.5))
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            Capsule()
                .foregroundColor(Color.green)
                .frame(width: 175, height: 45)
                .overlay(Text("Login"))
        }.padding(.horizontal, 15)
    }
}

struct AccountSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        AccountSignUpView()
    }
}
