//
//  OrganizationInfoCard.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/3/23.
//

import SwiftUI

struct OrganizationInfoCard: View {
    @Binding var organizationData: OrganizationInformationModel?

    @Binding var expandInfo: Bool

    @State var infoSubviewHeight: CGFloat = 0
    @State var showingCallAlert = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .foregroundColor(.clear)
                .overlay(
                    HStack {
                        Label {
                            Text("About Organization").bold()
                        } icon: {
                            Image(systemName: "info.circle.fill")
                        }
                        Spacer()
                    }
                )
            VStack {
                HStack {
                    Text("Name: ")
                        .bold()
                    Text(organizationData?.name ?? "Loading")
                    Spacer()
                }
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("Address: ")
                        .bold()
                    Text(organizationData?.address ?? "Loading")
                    Spacer()
                }
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("Email: ")
                        .bold()
                    Text(organizationData?.email ?? "Loading")
//                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            sendEmail(to: organizationData!.email)
                        }
                    Spacer()
                }
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("Phone: ")
                        .bold()
                    Text(organizationData?.phone.formattedPhoneNumber() ?? "Loading")
                    Image(systemName: "phone.fill.arrow.up.right")
//                        .foregroundColor(.blue)
                        .onTapGesture {
                            showingCallAlert = true
                        }
                        .alert(isPresented: $showingCallAlert) {
                            let telephoneURL = URL(string: "tel:\(organizationData!.phone)")
                            return Alert(
                                title: Text("Call \(organizationData!.phone.formattedPhoneNumber())"),
                                message: nil,
                                primaryButton: .default(Text("Call")) {
                                    UIApplication.shared.open(telephoneURL!)
                                },
                                secondaryButton: .cancel()
                            )
                        }
                    Spacer()
                }
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
                HStack {
                    Text("Website: ")
                        .bold()
                    Text(organizationData?.website ?? "Loading")
//                        .foregroundColor(.blue)
                        .underline()
                        .onTapGesture {
                            if organizationData?.website != nil {
                                guard let url = URL(string: "https://\(organizationData!.website)") else { return }
                                if UIApplication.shared.canOpenURL(url) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            

                        }
                    Spacer()
                }
                .padding(.vertical, 10)
                .fixedSize(horizontal: false, vertical: true)
            }
        }.background(GeometryReader {
            Color.clear.preference(key: ViewHeightKey.self,
                                   value: $0.frame(in: .local).size.height)
        })
        .onPreferenceChange(ViewHeightKey.self) { infoSubviewHeight = $0 }
        .frame(height: expandInfo ? infoSubviewHeight : 35, alignment: .top)
        .padding()
        .clipped()
        .transition(.move(edge: .bottom))
        .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)))
        .onTapGesture {
            print("organizationData: ", organizationData?.address ?? "Loading")
            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
            hapticResponse.impactOccurred()
            withAnimation(.spring()) {
                expandInfo.toggle()
            }
        }
        .cornerRadius(20)
    }
}
extension OrganizationInfoCard {
    func sendEmail(to recipient: String) {
        guard let url = URL(string: "mailto:\(recipient)") else { return }
        UIApplication.shared.open(url)
    }
}


private struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}

struct SpecialRequirementsInfoCard: View {
    var specialRequirements: String = "No special requirements. Anyone can volunteer!"
    @Binding var expandInfo: Bool

    @State var infoSubviewHeight: CGFloat = 0

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(height: 40)
                .foregroundColor(.clear)
                .overlay(
                        HStack {
                            Label {
                                Text("Special Requirements").bold()
                            } icon: {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.yellow)
                            }
                            Spacer()
                        }
                )
            VStack {
                Text(specialRequirements)
                    .font(.caption)
                
                    .padding(.top, 5)
                    .padding(.vertical, 10)
                    .fixedSize(horizontal: false, vertical: true)
            }
                    
                
        
        
        }.background(GeometryReader {
            Color.clear.preference(key: ViewHeightKey.self,
                                   value: $0.frame(in: .local).size.height)
        })
        .onPreferenceChange(ViewHeightKey.self) { infoSubviewHeight = $0 }
        .frame(height: expandInfo ? infoSubviewHeight : 35, alignment: .top)
        .padding()
        .clipped()
        .transition(.move(edge: .bottom))
        .background(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.4)))
        .onTapGesture {
            let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
            hapticResponse.impactOccurred()
            withAnimation(.spring()) {
                expandInfo.toggle()
            }
        }
        .cornerRadius(20)
    }
}
