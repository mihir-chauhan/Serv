//
//  AccountSignUpView.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/9/22.
//

import SwiftUI

struct AccountSignUpView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @ObservedObject private var combineViewModel = FormValidationSignUp()
    @Binding var goToRegistration: Bool
    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var birthYear: Int = 0
    @State var selectBirthYearSheet: Bool = false
    
    @State var birthYearAlert: Bool = false
    
    @State var disableSubmitButton: Bool = false
    
    //    init(combineViewModel: FormValidationUsingCombine = FormValidationUsingCombine()) {
    //          self.combineViewModel = combineViewModel
    //      }
    var buttonOpacity: Double {
        return combineViewModel.isValid ? 1 : 0.5
    }
    
    var body: some View {
        VStack(alignment: .leading) {
                Text("Sign Up").font(.largeTitle).bold()
                    .padding()

            VStack {
                    Form {
                        Section(header: Text("name"), footer: Text("Please use your full name, this is what event hosts will go by").fixedSize(horizontal: false, vertical: true)) {

                            TextField("Name", text: $combineViewModel.username)
                                .disableAutocorrection(true)

                        }

                        Section(header: Text("Email"), footer: Text(combineViewModel.inlineErrorForEmail).foregroundColor(.red)) {

                            TextField("Email", text: $combineViewModel.email)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                                .disableAutocorrection(true)

                        }
                        Section(header: Text("password"), footer: Text(combineViewModel.inlineErrorForPassword).foregroundColor(.red)) {

                            
                            SecureField("Password", text: $combineViewModel.password)
                            SecureField("Confirm Password", text: $combineViewModel.passwordAgain)

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
                        AgeVerification(showView: $selectBirthYearSheet, code: $birthYear)
//                            .presentationDetents([.fraction(0.15)])
                    }
                
                Button(action: {
                    if birthYear == 0 {
                        birthYearAlert = true
                    } else {
                        viewModel.createUser(name: combineViewModel.username, username: "", email: combineViewModel.email, password: combineViewModel.password)
                    }
                }) {
                    Capsule()
                        .foregroundColor(!combineViewModel.isValid ? Color.green.opacity(0.3) : Color.green)
                        .frame(width: 175, height: 45)
                        .overlay(Text("Sign Up").foregroundColor(Color.black).bold())
                        .padding()
                }.disabled(!combineViewModel.isValid)
                Text(viewModel.inlineErrorDialog).foregroundColor(.red).bold().fixedSize()
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
//            .background(Color(.systemGray6))
            .background(Color("signUpBgColor"))
        }
    }


