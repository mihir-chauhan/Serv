//
//  OnboardingFlow.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/25/22.
//

import SwiftUI

struct OnboardingManager: View {
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @State var currentIndex = 0
    @State var shouldShowOnboarding: Bool = true
    private func switchColor() -> Color {
        let tabColor = Color.green
//       let tabColor = TabColor(rawValue: currentIndex) ?? .one
       return tabColor
     }
    var body: some View {
        if !hasOnboarded {
            OnboardingView()
        } else {
            CustomTabBar()
        }
    }
}

struct OnboardingView: View {
    @AppStorage("hasOnboarded") var hasOnboarded: Bool = false
    @State var pageIndex = 0
    @State var numberOfPages = dummyOnboardingPages.count
    let passedOnboarding = UserDefaults.standard
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $pageIndex) {
                    ForEach(dummyOnboardingPages, id: \.placement) { page in
                        // MARK: make the images pngs
                        SingularOnboardingPageView(page: page)
                            .tag(page.placement)
                    }
                    var _ = print(pageIndex)
                }.tabViewStyle(.page(indexDisplayMode: .never))
                //        .indexViewStyle(.page(backgroundDisplayMode: .always))
                Group {
                    
                        Button(action: {
                            if pageIndex < 3 {
                                withAnimation {
                                    pageIndex += 1
                                }
                            }
                            if pageIndex == 3 {
                                withAnimation(Animation.easeOut(duration: 0.3)) {
                                    self.hasOnboarded = true
                                }
                            }
                        }) {
                            if pageIndex < 3 {
                            Circle()
                                .foregroundColor(.white)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 25, height: 25)
                                    
                                        .symbolRenderingMode(.none)
                                )
                            
                                .frame(width: 50, height: 50)
                            }
                                if pageIndex == 3 {
                                    Capsule()
                                        .frame(width: 105, height: 50)
                                        .overlay(
                                            Text("Get started")
                                                .foregroundColor(.white)
                                        )
                                }
                            
                        }.padding(20)
                    }
                    
            }
            
            
            UIPageControlView(currentPage: $pageIndex, numberOfPages: $numberOfPages)
                .frame(maxWidth: 0, maxHeight: 0)
                .padding(.bottom, 40)
            
        }.edgesIgnoringSafeArea(.all)
    }
}

struct SingularOnboardingPageView: View {
    var page: SingularOnboardingPage
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                Image(page.image)
                Text(page.description)
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(page.color)
    }
}

struct SingularOnboardingPage {
    var placement: Int
    var color: Color
    var image: String
    var description: String
}

let dummyOnboardingPages: [SingularOnboardingPage] = [
    SingularOnboardingPage(placement: 0, color: .green, image: "leaderboardPic-1", description: "lorem ipsum"),
    SingularOnboardingPage(placement: 1, color: .blue, image: "leaderboardPic-2", description: "lorem ipsum"),
    SingularOnboardingPage(placement: 2, color: .mint, image: "leaderboardPic-3", description: "lorem ipsum"),
    SingularOnboardingPage(placement: 3, color: .orange, image: "leaderboardPic-2", description: "lorem ipsum"),
]

struct UIPageControlView: UIViewRepresentable {
    @Binding var currentPage: Int
    @Binding var numberOfPages: Int
    
    func makeUIView(context: Context) -> UIPageControl {
        let uiView = UIPageControl()
        uiView.backgroundStyle = .prominent
        uiView.currentPage = currentPage
        uiView.numberOfPages = numberOfPages
        return uiView
    }
    
    func updateUIView(_ uiView: UIPageControl, context: Context) {
        uiView.currentPage = currentPage
        uiView.numberOfPages = numberOfPages
    }
}
