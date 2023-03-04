//
//  OnboardingFlow.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/25/22.
//

import SwiftUI

let onBoardingImages: [SingularOnboardingPage] = [
    SingularOnboardingPage(placement: 0, color: .white, image: "onBoard-0", title: "Browse Opportunities", description: "Find service events from different categories posted by verified organizations near you"),
    SingularOnboardingPage(placement: 1, color: .white, image: "onBoard-1", title: "Attend events", description: "Sign up and attend for upcoming events to earn service hours"),
    SingularOnboardingPage(placement: 2, color: .white, image: "onBoard-2", title: "Connect with Friends", description: "See what events your friends are planning to attend"),
    SingularOnboardingPage(placement: 3, color: .white, image: "onBoard-3", title: "Keeping track", description: "Keep track of your valid service hours and apply for the President's Volunteer Service Award!"),
]

struct OnboardingView: View {
    @EnvironmentObject var viewModel: LocationTrackerViewModel
    @Binding var hasOnboarded: Bool
    @State var pageIndex = 0
    @State var numberOfPages = onBoardingImages.count
    let passedOnboarding = UserDefaults.standard
    var body: some View {
        ZStack(alignment: .bottom) {
            ZStack(alignment: .bottomTrailing) {
                TabView(selection: $pageIndex) {
                    ForEach(onBoardingImages, id: \.placement) { page in
                        SingularOnboardingPageView(page: page)
                            .tag(page.placement)
                    }
                }.tabViewStyle(.page(indexDisplayMode: .never))
                Group {
                    
                    Button(action: {
                        if pageIndex < 4 {
                            withAnimation(Animation.easeInOut) {
                                pageIndex += 1
                            }
                        }
                        if pageIndex == 4 {
                            viewModel.checkIfLocationServicesIsEnabled(limitResults: true)
                            withAnimation(Animation.easeOut(duration: 0.3)) {
                                self.hasOnboarded = true
                            }
                        }
                    }) {
                        if pageIndex < 3 {
                            Circle()
                                .foregroundColor(.neuWhite)
                                .overlay(
                                    Image(systemName: "chevron.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                        .symbolRenderingMode(.none)
                                )
                                .frame(width: 50, height: 50)
                        }
                        if pageIndex == 3 {
                            Circle()
                                .foregroundColor(.neuWhite)
                                .overlay(
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 15, height: 15)
                                    
                                        .symbolRenderingMode(.none)
                                )
                                .frame(width: 50, height: 50)
                        }
                        
                    }.padding(20)
                }
                
            }
            
            
            UIPageControlView(currentPage: $pageIndex, numberOfPages: $numberOfPages)
                .frame(maxWidth: 0, maxHeight: 0)
                .padding(.bottom, 40)
                .id(pageIndex)
                .allowsHitTesting(false)
            
            
        }.edgesIgnoringSafeArea(.all)
    }
}

struct SingularOnboardingPageView: View {
    var page: SingularOnboardingPage
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .center) {
                Image(page.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: UIScreen.main.bounds.height * (2/3))
                VStack(alignment: .leading) {
                    Text(page.title)
                        .font(.title).bold()
                    
                    Text(page.description)
                        .font(.subheadline).bold()
                }.padding()
            }.padding()
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct SingularOnboardingPage {
    var placement: Int
    var color: Color
    var image: String
    var title: String
    var description: String
}

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
