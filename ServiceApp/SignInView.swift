//
//  SignInView.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/9/22.
//

import SwiftUI
import AuthenticationServices



struct SignInView: View {
    @Environment(\.colorScheme) var colorScheme

    @EnvironmentObject var viewModel: AuthViewModel
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    @State var goIntoRegistration: Bool = false
    @State var credentialsAreFilled: Bool = false
    
    @State var displayNameEntered: String = ""
    @State var newConfirmPasswordEntered: String = ""
    
    var body: some View {
        NavigationView {
            if goIntoRegistration {
                VStack {
                    Group {
                        VStack(alignment: .trailing, spacing: 10) {
                            HStack {
                                TextField("Display Name", text: $displayNameEntered).autocapitalization(.none).keyboardType(.emailAddress)
                            }.padding(10)
                            .background(Color.mint.opacity(0.2))
                            .cornerRadius(12)
                            HStack {
                                TextField("Email", text: $usernameEntered).autocapitalization(.none).keyboardType(.emailAddress)
                            }.padding(10)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(12)
                            HStack {
                                SecureField("Password", text: $passwordEntered)
                            }.padding(10)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(12)
                            HStack {
                                SecureField("Confirm Password", text: $newConfirmPasswordEntered)
                            }.padding(10)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(12)
                            
                            Button(action: {
                                // TODO: We need to validate email with regex and that passwords match
//                                viewModel.createUser(displayName: displayNameEntered, email: usernameEntered, password: passwordEntered)
                            }) {
                                Capsule()
                                    .frame(width: 100, height: 35)
                                    .foregroundColor(.mint)
                                    .overlay(Text("Sign Up").foregroundColor(.white))
                            }
                        }.padding(35)
                        Button("I have an account") {
                            goIntoRegistration = false
                        }
                    }
                }.navigationTitle("Welcome")
            }
            else {
                ZStack {
                    if viewModel.loading == true {
                        ProgressView()
                            .frame(width: 50, height: 50)
                            .background(CustomMaterialEffectBlur())
                            .cornerRadius(15)
                    }
                    VStack {
                        Group {
                            VStack(alignment: .trailing, spacing: 10) {
                                HStack {
                                    TextField("Email", text: $usernameEntered).autocapitalization(.none).keyboardType(.emailAddress)
                                }.padding(10)
                                    .background(Color.mint.opacity(0.2))
                                    .cornerRadius(12)
                                HStack {
                                    SecureField("Password", text: $passwordEntered)
                                }
                                .padding(10)
                                .background(Color.mint.opacity(0.2))
                                .cornerRadius(12)
                                
                                Button(action: {
                                    viewModel.emailPwdSignIn(email: usernameEntered, password: passwordEntered)
                                }) {
                                    Capsule()
                                        .frame(width: 100, height: 35)
                                        .foregroundColor(.mint)
                                        .overlay(Text("Log in").foregroundColor(.white))
                                }
                            }.padding(35)
                        }
                        VStack(spacing: 15) {
                            Button(action: {
                                
                                viewModel.gAuthSignIn()
                                
                            }) {
                                HStack {
                                    Image("google")
                                        .resizable()
                                        .frame(width: 20, height: 20)
                                        .aspectRatio(contentMode: .fit)
                                    
                                    Text("Continue with Google")
                                        .foregroundColor(colorScheme == .dark ? .white : .black)
                                }
                                .frame(width: 280, height: 45, alignment: .center)
                                .overlay(
                                    Capsule()
                                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                                        .foregroundColor(Color(.sRGB, red: 241/255, green: 246/255, blue: 247/255))
                                )
                                .clipShape(Capsule())
                            }
                            
                            SignInWithAppleButton(
                                .signIn,
                                onRequest: { request in
                                    viewModel.appleOnRequest(request: request)
                                },
                                onCompletion: { result in
                                    viewModel.appleOnCompletion(result: result)
                                })
                                .frame(width: 280, height: 45, alignment: .center)
                                .overlay(
                                    Capsule()
                                        .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                                        .foregroundColor(Color(.sRGB, red: 241/255, green: 246/255, blue: 247/255))
                                )
                                .clipShape(Capsule())
                                .padding(.bottom, 20)
                            
                            //            Button(action: {
                            //                viewModelForEP.createUser(email: "random@gmail.com", password: "random_modnar")
                            //            }) {
                            //                Text("Register with email")
                            //            }
                            
                            Button("Create an account") {
                                goIntoRegistration = true
                            }
                        }
                    }
                }.navigationTitle("Welcome")
            }
        }
    }
}

             
