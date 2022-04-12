//
//  AccountSignUpView.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/9/22.
//

import SwiftUI

struct AccountSignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var goToRegistration: Bool
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var usernameEntered: String = ""
    @State var emailEntered: String = ""
    @State var passwordEntered: String = ""
    @State var confirmPassword: String = ""
    
    @State var disableSubmitButton: Bool = true
    var body: some View {
        VStack {
            Spacer(minLength: 30)
            VStack {
                HStack {
                    HStack (alignment: .center, spacing: 10) {
                        Image(systemName: "person.fill")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color.mint.opacity(0.5))
                        
                        TextField("First Name", text: $firstName)
                        
                    }
                    .padding(10)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(15)
                    
                    TextField("Last Name", text: $lastName)
                        .padding(10)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(15)
                }
            }
            Text("Use your full name, this is what event hosts will go by")
                .font(.caption)
                .padding(.bottom, 40)
            HStack (alignment: .center, spacing: 10) {
                Image(systemName: "at.circle.fill")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.mint.opacity(0.5))
                
                TextField("Username", text: $usernameEntered)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            HStack (alignment: .center, spacing: 10) {
                Image(systemName: "envelope.fill")
                    .resizable()
                    .frame(width: 25, height: 20)
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(Color.mint.opacity(0.5))
                
                TextField("Email", text: $emailEntered)
            }
            .padding(10)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(15)
            
            .padding(.bottom, 25)
            VStack {
                HStack (alignment: .center, spacing: 10) {
                    Image(systemName: "lock.fill")
                        .resizable()
                        .frame(width: 23, height: 23)
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
                        .frame(width: 23, height: 23)
                        .aspectRatio(contentMode: .fit)
                        .foregroundColor(Color.mint.opacity(0.5))
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                .padding(10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(15)
            }
            Button(action: {
                viewModel.createUser(firstName: firstName, lastName: lastName, username: usernameEntered, email: emailEntered, password: passwordEntered)
            }) {
            Capsule()
                    .foregroundColor(disableSubmitButton ? Color.green.opacity(0.3) : Color.green)
                .frame(width: 175, height: 45)
                .overlay(Text("Sign Up"))
                
            }.disabled(disableSubmitButton ? true : false)
            Spacer(minLength: 30)
            Button(action: {
                withAnimation {
                    goToRegistration = false
                }
            }) {
                Text("I have an account")
                    .padding()
            }
        }.padding(.horizontal, 35)
    }
}

