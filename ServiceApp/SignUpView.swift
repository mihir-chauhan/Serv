//
//  SignUpView.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/12/22.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = AuthViewModel()
    @State var displayNameEntered: String = ""
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    @State var confirmPasswordEntered: String = ""
    var body: some View {
        VStack {
            Group {
                VStack(alignment: .trailing, spacing: 10) {
                    HStack {
                        TextField("Display Name", text: $displayNameEntered).autocapitalization(.none).keyboardType(.emailAddress)
                    }.padding(10)
                    .background(Color.mint.opacity(0.2))
                    .cornerRadius(12)
                    HStack {
                        TextField("Username", text: $usernameEntered).autocapitalization(.none).keyboardType(.emailAddress)
                    }.padding(10)
                        .background(Color.mint.opacity(0.2))
                        .cornerRadius(12)
                    HStack {
                        SecureField("Password", text: $passwordEntered)
                    }.padding(10)
                        .background(Color.mint.opacity(0.2))
                        .cornerRadius(12)
                    HStack {
                        SecureField("Confirm Password", text: $confirmPasswordEntered)
                    }.padding(10)
                        .background(Color.mint.opacity(0.2))
                        .cornerRadius(12)
                    
                    
                    Button(action: {
                        viewModel.createUser(displayName: displayNameEntered, email: usernameEntered, password: passwordEntered)
                    }) {
                        Capsule()
                            .frame(width: 100, height: 35)
                            .foregroundColor(.mint)
                            .overlay(Text("Sign Up"))
                    }
                }.padding()
            }
        }
    }
}


