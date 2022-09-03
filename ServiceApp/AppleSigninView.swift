import Foundation
import SwiftUI
import FirebaseAuth
import AuthenticationServices
import CryptoKit
import GoogleSignIn
import UIKit


struct AppleSignInView: View {
    var body: some View {
        UIViewControllerAdapter()
    }
}

//struct QuickSignInWithApple: UIViewRepresentable {
//    typealias UIViewType = ASAuthorizationAppleIDButton
//
//    func makeUIView(context: Context) -> UIViewType {
//        ASAuthorizationAppleIDButton(type: .signIn, style: .white)
//        AuthViewController().perfo
//    }
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//      }
//}

class AuthViewController: UIViewController {
    override func loadView() {
        view = UITableView(frame: .zero, style: .insetGrouped)
      }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let signInButton = ASAuthorizationAppleIDButton(type: .signIn, style: .white)
        signInButton.addTarget(self, action: #selector(performAppleSignInFlow), for: .touchUpInside)
        self.view.addSubview(signInButton)
//        configureNavigationBar()
//        configureDataSourceProvider()
      }
    
//    performAppleSignInFlow()
    
    var currentNonce: String?
    @objc private func performAppleSignInFlow() {
      let nonce = randomNonceString()
      currentNonce = nonce
      let appleIDProvider = ASAuthorizationAppleIDProvider()
      let request = appleIDProvider.createRequest()
      request.requestedScopes = [.fullName, .email]
      request.nonce = sha256(nonce)

      let authorizationController = ASAuthorizationController(authorizationRequests: [request])
      authorizationController.delegate = self
      authorizationController.presentationContextProvider = self
      authorizationController.performRequests()
    }
}

extension AuthViewController: ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding {
  // MARK: ASAuthorizationControllerDelegate
  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithAuthorization authorization: ASAuthorization) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
    else {
      print("Unable to retrieve AppleIDCredential")
      return
    }

    guard let nonce = currentNonce else {
      fatalError("Invalid state: A login callback was received, but no login request was sent.")
    }
    guard let appleIDToken = appleIDCredential.identityToken else {
      print("Unable to fetch identity token")
      return
    }
    guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
      print("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
      return
    }

    let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                              idToken: idTokenString,
                                              rawNonce: nonce)

    Auth.auth().signIn(with: credential) { result, error in
      // Error. If error.code == .MissingOrInvalidNonce, make sure
      // you're sending the SHA256-hashed nonce as a hex string with
      // your request to Apple.
      guard error == nil else { return  }

      // At this point, our user is signed in
      // so we advance to the User View Controller
//      self.transitionToUserViewController()
    }
  }

  func authorizationController(controller: ASAuthorizationController,
                               didCompleteWithError error: Error) {
    // Ensure that you have:
    //  - enabled `Sign in with Apple` on the Firebase console
    //  - added the `Sign in with Apple` capability for this project
    print("Sign in with Apple errored: \(error)")
  }

  // MARK: ASAuthorizationControllerPresentationContextProviding
  func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    return view.window!
  }

  // MARK: Aditional `Sign in with Apple` Helpers
  // Adapted from https://auth0.com/docs/api-auth/tutorials/nonce#generate-a-cryptographically-random-nonce
  private func randomNonceString(length: Int = 32) -> String {
    precondition(length > 0)
    let charset: [Character] =
      Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length

    while remainingLength > 0 {
      let randoms: [UInt8] = (0 ..< 16).map { _ in
        var random: UInt8 = 0
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
        if errorCode != errSecSuccess {
          fatalError(
            "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
          )
        }
        return random
      }

      randoms.forEach { random in
        if remainingLength == 0 {
          return
        }

        if random < charset.count {
          result.append(charset[Int(random)])
          remainingLength -= 1
        }
      }
    }

    return result
  }

  private func sha256(_ input: String) -> String {
    let inputData = Data(input.utf8)
    let hashedData = SHA256.hash(data: inputData)
    let hashString = hashedData.compactMap {
      String(format: "%02x", $0)
    }.joined()

    return hashString
  }
}


struct UIViewControllerAdapter: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) ->  AuthViewController {
        return AuthViewController()
    }
    
    func updateUIViewController(_ uiViewController: AuthViewController, context: Context) {
        
    }
}
