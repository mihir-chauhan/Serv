//
//  SignInView.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/9/22.
//

import SwiftUI
import AuthenticationServices



struct SignInView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    @State var goIntoRegistration: Bool = false
    @State var credentialsAreFilled: Bool = false
//    {
//        get {
//            if !usernameEntered.isEmpty && !passwordEntered.isEmpty {
//                return true
//            }
//        }
//        set (v) {
//
//        }
//
//    }()
//
    var body: some View {
        NavigationView {
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
                        TextField("username", text: $usernameEntered).keyboardType(.emailAddress)
                    }.padding(10)
                        .background(Color.mint.opacity(0.2))
                        .cornerRadius(12)
                    HStack {
                        SecureField("password", text: $passwordEntered)
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
                        .overlay(Text("Log in").foregroundColor(credentialsAreFilled ? .white : .gray))
                    }
                }.padding(35)
            }
//                if !usernameEntered.isEmpty && !passwordEntered.isEmpty {
//                    Button(action: {
//                        viewModelForEP.signIn(email: usernameEntered, password: passwordEntered)
//                        credentialsAreFilled = true
//                    }) {
//                        Text("Log in")
//                    }
//                }
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
                                .foregroundColor(.black)
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
                        onRequest: { request in
                            viewModel.appleOnRequest(request: request)
                        },
                        onCompletion: { result in
                            viewModel.appleOnCompletion(result: result)
                        })
                        .frame(width: 280, height: 45, alignment: .center)
                        .clipShape(Capsule())
                    
                    //            Button(action: {
                    //                viewModelForEP.createUser(email: "random@gmail.com", password: "random_modnar")
                    //            }) {
                    //                Text("Register with email")
                    //            }
                    
                    NavigationLink(destination: SignUpView(), isActive: $goIntoRegistration) {
                        Button("Create an account") {
                            goIntoRegistration = true
                        }
                    }
                }
            }
            }
                .navigationTitle("Welcome")
        }
    }
}

             
