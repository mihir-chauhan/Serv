//
//  NewForm2.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/24/22.
//

import Combine
import SwiftUI

class FormValidationSignUp: ObservableObject {
    @Published var username = ""
    @Published var email = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var isValid = false
    
    @Published var inlineErrorForUsername = ""
    @Published var inlineErrorForEmail = ""
    @Published var inlineErrorForPassword = ""
    
    
    var cancellables = Set<AnyCancellable>()
    private static let predicate = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[!@#$%^&*]).{6,}$")
    
    private var isUsernameValidPublisher: AnyPublisher<Bool, Never> {
        $username
            //debounce = a little asyncAfter work. Will display error message few moments after user stops typing
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates() //will not care is items are the same. Will only look for things that are different
            .map { $0.count >= 3 } //if does not >= 3, then it will return false
            .eraseToAnyPublisher()
    }
    
    private var isUserEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
//            .map{ Self.predicate.evaluate(with: $0) }
            .map { email in
                let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
                return emailPred.evaluate(with: email)
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.8, scheduler: RunLoop.main)
            .removeDuplicates()
            .map { $0.isEmpty }
            .eraseToAnyPublisher()
    }
    private var arePasswordEqualPublisher: AnyPublisher<Bool, Never> {
        //CombineLatest is when you take two publishers and compare them
        //this is just like the other func, but you just have two publishers
        Publishers.CombineLatest($password, $passwordAgain)
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map{ $0 == $1 }
            .eraseToAnyPublisher()
    }
    private var isPasswordStrong: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            //only publishes elements that don't match the previous element
            
            .removeDuplicates()
            .map{ Self.predicate.evaluate(with: $0) }
            .eraseToAnyPublisher()
    }
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, arePasswordEqualPublisher, isPasswordStrong)
            .map {
                if $0 { return PasswordStatus.empty }
                if !$1 { return PasswordStatus.repeatedPasswordWrong }
                if !$2 { return PasswordStatus.notStrongEnough }
                
                return PasswordStatus.valid
            }
            .eraseToAnyPublisher()
    }
    
    
    private var isFormValid: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3(isUsernameValidPublisher, isUserEmailValidPublisher, isPasswordValidPublisher)
            .map {
                if ($0 == true && $1 == true && $2 == .valid) {
                    return true
                }
                return false
            }
            .eraseToAnyPublisher()
    }
    init() {
        isFormValid
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
        
        isUserEmailValidPublisher
            .dropFirst()
            .map { value -> String in
                switch value {
                case false:
                    return "Enter a valid email"
                case true:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForEmail, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            //when the main UI will receive it
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty!"
                case .notStrongEnough:
                    return "Password not strong enough"
                case .repeatedPasswordWrong:
                    return "Password do not match"
                case .valid:
                    return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cancellables)
            
    }
}

enum PasswordStatus {
    case empty
    case notStrongEnough
    case repeatedPasswordWrong
    case valid
}
