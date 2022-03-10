//
//  SignInView.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/9/22.
//

import SwiftUI
import AuthenticationServices


struct AuthViewManager: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        //        switch viewModel.state {
        //        case .signedIn: SignedInView()
        //        case .signedOut: SignInView()
        //        }
        SignInView()
    }
}

struct SignInView: View {
    @StateObject var viewModel = AuthViewModel()
    @StateObject var viewModelForEP = EPAuthViewModel()
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    
    var body: some View {
        Group {
            HStack {
                TextField("username", text: $usernameEntered).keyboardType(.emailAddress)
                if !usernameEntered.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray2))
                        .padding(.horizontal, 3)
                        .onTapGesture {
                            self.usernameEntered = ""
                        }
                }
            }.padding(10)
                .background(Color.white.opacity(0.5))
                .cornerRadius(12)
            HStack {
                TextField("password", text: $passwordEntered)
                if !passwordEntered.isEmpty {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(Color(.systemGray2))
                        .padding(.horizontal, 3)
                        .onTapGesture {
                            self.passwordEntered = ""
                        }
                }
            }
            .padding(10)
            .background(Color.white.opacity(0.5))
            .cornerRadius(12)
        }
        if !usernameEntered.isEmpty && !passwordEntered.isEmpty {
            Button(action: {
                viewModelForEP.signIn(email: usernameEntered, password: passwordEntered)
            }) {
                Text("Log in")
            }
        }
        Button(action: {
            viewModel.gAuthSignIn()
        }) {
            HStack {
                Image("google")
                    .resizable()
                    .frame(width: 20, height: 20)
                    .aspectRatio(contentMode: .fit)
                
                Text("Continue with Google")
                    .foregroundColor(.black)
            }
            .frame(width: 280, height: 45, alignment: .center)
            .foregroundColor(Color.neuWhite)
            .overlay(
                Capsule()
                    .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
            )
            .clipShape(Capsule())
        }
        SignInWithAppleButton(
            onRequest: { request in
                viewModel.appleOnRequest(request: request)
            },
            onCompletion: { result in
                viewModel.appleOnCompletion(result: result)
            })
            .frame(width: 280, height: 45, alignment: .center)
            .clipShape(Capsule())
        
        Button(action: {
            viewModelForEP.createUser(email: "random@gmail.com", password: "random_modnar")
        }) {
            Text("Register with email")
        }
    }
}

             
