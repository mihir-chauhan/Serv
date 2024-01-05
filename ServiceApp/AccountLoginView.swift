//
//  AccountLogin2.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/8/22.
//

import SwiftUI
import AuthenticationServices
import Combine


struct AccountLoginView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @Environment(\.colorScheme) var colorScheme
    @State var usernameEntered: String = ""
    @State var passwordEntered: String = ""
    
    @State var goIntoRegistration: Bool = false
    var body: some View {
        Group {
            if goIntoRegistration == false {
                
                VStack(alignment: .leading) {
                    Text("Welcome").font(.largeTitle).bold()
                        .padding(.bottom)
                    
                    Section(header: Text("Sign in").font(.headline).bold(), footer: Text(authVM.signInDialogMessage).foregroundColor(.red).font(.caption).bold()) {
                        TextField ("Email", text: $usernameEntered)
                            .disableAutocorrection(true)
                            .autocapitalization(.none)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                        
                        SecureField("Password", text: $passwordEntered)
                            .padding(12)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(15)
                    }
                    
                    HStack {
                        Spacer(minLength: 20)
                        Text("Sign Up")
                            .underline()
                            .bold()
                            .foregroundColor(.mint.opacity(0.5))
                            .onTapGesture {
                                withAnimation {
                                    self.goIntoRegistration = true
                                }
                            }
                    }.padding()
                }
                .padding(.horizontal, 40)
                
                Capsule()
                    .foregroundColor(Color("colorPrimary"))
                    .frame(width: 175, height: 45)
                    .overlay(Text("Login"))
                    .onTapGesture(perform: {
                        authVM.emailPwdSignIn(email: usernameEntered, password: passwordEntered)
                    })
                Text("————————— or —————————")
                    .font(.subheadline)
                    .foregroundColor(Color(.systemGray))
                    .padding(32)
                VStack {
                    Button(action: {
                        
                        authVM.gAuthSignIn()
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
                    AppleSignInView()
                        .overlay(
                            Capsule()
                                .stroke(Color(.sRGB, red: 150/255, green: 150/255, blue: 150/255, opacity: 0.3), lineWidth: 2)
                                .foregroundColor(Color(.sRGB, red: 241/255, green: 246/255, blue: 247/255))
                        )
                        .clipShape(Capsule())
                        .padding(.bottom, 20)
                    
                    Button(action: {
                        
                        authVM.authenticateGithub()
                    }) {
                        HStack {
                            Image("google")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .aspectRatio(contentMode: .fit)
                            
                            Text("Continue with GitHub")
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
                }
            }
            else {
                AccountSignUpView(goToRegistration: $goIntoRegistration)
            }
        }.ignoresSafeArea(.keyboard)
    }
}

struct AccountLogin2_Previews: PreviewProvider {
    static var previews: some View {
        AccountLoginView()
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}

struct SizePreferenceKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
struct BackgroundGeometryReader: View {
    var body: some View {
        GeometryReader { geometry in
            return Color
                .clear
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
}
struct SizeAwareViewModifier: ViewModifier {
    
    @Binding private var viewSize: CGSize
    
    init(viewSize: Binding<CGSize>) {
        self._viewSize = viewSize
    }
    
    func body(content: Content) -> some View {
        content
            .background(BackgroundGeometryReader())
            .onPreferenceChange(SizePreferenceKey.self, perform: { if self.viewSize != $0 { self.viewSize = $0 }})
    }
}

struct SegmentedPicker: View {
    private static let ActiveSegmentColor: Color = Color(.tertiarySystemBackground)
    private static let BackgroundColor: Color = Color(.secondarySystemBackground)
    private static let ShadowColor: Color = Color.black.opacity(0.2)
    private static let TextColor: Color = Color(.secondaryLabel)
    private static let SelectedTextColor: Color = Color(.label)
    
    private static let TextFont: Font = .system(size: 12)
    
    private static let SegmentCornerRadius: CGFloat = 12
    private static let ShadowRadius: CGFloat = 4
    private static let SegmentXPadding: CGFloat = 16
    private static let SegmentYPadding: CGFloat = 8
    private static let PickerPadding: CGFloat = 4
    
    private static let AnimationDuration: Double = 0.1
    
    // Stores the size of a segment, used to create the active segment rect
    @State private var segmentSize: CGSize = .zero
    // Rounded rectangle to denote active segment
    private var activeSegmentView: AnyView {
        // Don't show the active segment until we have initialized the view
        // This is required for `.animation()` to display properly, otherwise the animation will fire on init
        let isInitialized: Bool = segmentSize != .zero
        if !isInitialized { return EmptyView().eraseToAnyView() }
        return
        RoundedRectangle(cornerRadius: SegmentedPicker.SegmentCornerRadius)
            .foregroundColor(SegmentedPicker.ActiveSegmentColor)
            .shadow(color: SegmentedPicker.ShadowColor, radius: SegmentedPicker.ShadowRadius)
            .frame(width: self.segmentSize.width, height: self.segmentSize.height)
            .offset(x: self.computeActiveSegmentHorizontalOffset(), y: 0)
            .animation(.spring(blendDuration: SegmentedPicker.AnimationDuration), value: self.computeActiveSegmentHorizontalOffset())
            .eraseToAnyView()
    }
    
    @Binding private var selection: Int
    private let items: [String]
    
    init(items: [String], selection: Binding<Int>) {
        self._selection = selection
        self.items = items
    }
    
    var body: some View {
        // Align the ZStack to the leading edge to make calculating offset on activeSegmentView easier
        ZStack(alignment: .leading) {
            // activeSegmentView indicates the current selection
            self.activeSegmentView
            HStack {
                ForEach(0..<self.items.count, id: \.self) { index in
                    self.getSegmentView(for: index)
                }
            }
        }
        .padding(SegmentedPicker.PickerPadding)
        .background(SegmentedPicker.BackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: SegmentedPicker.SegmentCornerRadius))
    }
    
    // Helper method to compute the offset based on the selected index
    private func computeActiveSegmentHorizontalOffset() -> CGFloat {
        CGFloat(self.selection) * (self.segmentSize.width + SegmentedPicker.SegmentXPadding / 2)
    }
    
    // Gets text view for the segment
    private func getSegmentView(for index: Int) -> some View {
        guard index < self.items.count else {
            return EmptyView().eraseToAnyView()
        }
        let isSelected = self.selection == index
        return
        Text(self.items[index])
        // Dark test for selected segment
            .foregroundColor(isSelected ? SegmentedPicker.SelectedTextColor: SegmentedPicker.TextColor)
            .lineLimit(1)
            .padding(.vertical, SegmentedPicker.SegmentYPadding)
            .padding(.horizontal, SegmentedPicker.SegmentXPadding)
            .frame(minWidth: 0, maxWidth: .infinity)
        // Watch for the size of the
            .modifier(SizeAwareViewModifier(viewSize: self.$segmentSize))
            .onTapGesture { self.onItemTap(index: index) }
            .eraseToAnyView()
    }
    
    // On tap to change the selection
    private func onItemTap(index: Int) {
        guard index < self.items.count else {
            return
        }
        self.selection = index
    }
}
