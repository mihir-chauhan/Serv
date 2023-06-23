//
//  AccountSignUpView.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/9/22.
//

import SwiftUI

struct AccountSignUpView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @ObservedObject private var formSignUpVM = FormValidationSignUp()
    @Binding var goToRegistration: Bool
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var birthYear: Int = 0
    @State var selectBirthYearSheet: Bool = false
    
    @State var birthYearAlert: Bool = false
    
    @State var disableSubmitButton: Bool = false
    
    
    var buttonOpacity: Double {
        return formSignUpVM.isValid ? 1 : 0.5
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Sign Up").font(.largeTitle).bold()
                .padding()
            
            VStack {
                Form {
                    Section(header: Text("name"), footer: Text("Please use your full name, this is what event hosts will go by").fixedSize(horizontal: false, vertical: true)) {
                        
                        TextField("Name", text: $formSignUpVM.username)
                            .disableAutocorrection(true)
                        
                    }
                    
                    Section(header: Text("Email"), footer: Text(formSignUpVM.inlineErrorForEmail).foregroundColor(.red)) {
                        
                        TextField("Email", text: $formSignUpVM.email)
                            .autocapitalization(.none)
                            .keyboardType(.emailAddress)
                            .disableAutocorrection(true)
                        
                    }
                    Section(header: Text("password"), footer: Text(formSignUpVM.inlineErrorForPassword).foregroundColor(.red)) {
                        
                        
                        SecureField("Password", text: $formSignUpVM.password)
                        SecureField("Confirm Password", text: $formSignUpVM.passwordAgain)
                        
                    }
                    
                    Section(header: Text("Birth year")) {
                        Button(action: {
                            self.selectBirthYearSheet.toggle()
                        }) {
                            HStack {
                                Text("Select Birth Year")
                                Spacer()
                                Text(verbatim: birthYear == 0 ? "" : "\(birthYear)")
                                //                                        .foregroundColor(.black)
                                    .bold()
                            }
                        }
                    }
                }.sheet(isPresented: $selectBirthYearSheet) {
                    AgeVerification(showView: $selectBirthYearSheet, code: $birthYear, dismissDisabled: true)
                }
                
                Button(action: {
                    if birthYear == 0 {
                        birthYearAlert = true
                    } else {
                        authVM.createUser(name: formSignUpVM.username, username: "", email: formSignUpVM.email, password: formSignUpVM.password, birthYear: birthYear)
                    }
                }) {
                    Capsule()
                        .foregroundColor(!formSignUpVM.isValid ? Color("colorPrimary").opacity(0.3) : Color("colorPrimary"))
                        .frame(width: 175, height: 45)
                        .overlay(Text("Sign Up").foregroundColor(Color.black).bold())
                        .padding()
                }.disabled(!formSignUpVM.isValid)
                Text(authVM.inlineErrorDialog).foregroundColor(.red).bold().fixedSize()
                Button(action: {
                    withAnimation {
                        goToRegistration = false
                    }
                }) {
                    Text("I have an account")
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                }
            }
        }.padding(.horizontal, 15)
            .ignoresSafeArea(.keyboard)
            .cornerRadius(20)
            .background(Color("signUpBgColor"))
    }
}


