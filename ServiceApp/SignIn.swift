//
//  SignIn.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/19/22.
//

import SwiftUI
import Firebase
import GoogleSignIn

struct SignIn: View {
    @State var isLoading: Bool = false
    var body: some View {
        Button(action: {
            handleLogin()
        }) {
            Text("Sign in with google")
        }
        .overlay(
            ZStack {
                if isLoading {
                    Color.black
                        .opacity(0.25)
                        .ignoresSafeArea()
                    ProgressView()
                        .font(.title2)
                        .frame(width: 60, height: 60)
                        .background(Color.white)
                        .cornerRadius(20)
                }
            }
        )
    }
    
    func handleLogin() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        
        let config = GIDConfiguration(clientID: clientID)
        isLoading = true
        
        GIDSignIn.sharedInstance.signIn(with: config, presenting: getRootViewController()) { user, err in
            if let error = err {
                isLoading = false
                print(error.localizedDescription)
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                isLoading = false
                return
                
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: authentication.accessToken)
            
//            Firebase Auth:
            Auth.auth().signIn(with: credential) { result, err in
                
                isLoading = false
                
                if let error = err {
                    print(error.localizedDescription)
                    return
                }
                
                guard let user = result?.user else {
                    return
                }
                
                print(user.displayName ?? "Success!")
            }
        }
    }
}

extension View {
    func getRect() -> CGRect {
        return UIScreen.main.bounds
    }
    
//    Retrieve root view controller
    func getRootViewController() -> UIViewController {
        guard
            let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let root = screen.windows.first?.rootViewController
        else { return .init() }
        return root
    }
}


