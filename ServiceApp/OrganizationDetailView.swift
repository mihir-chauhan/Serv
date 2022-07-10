//
//  OrganizationDetailView.swift
//  ServiceApp
//
//  Created by Kelvin J on 7/9/22.
//

import SwiftUI

struct OrganizationDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    let FIRclass = FirestoreCRUD()
    @State var data: OrganizationInformationModel?
    var ein: String
    
    func urlDetector(urlString: String) {
        let input = data!.website
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        let matches = detector.matches(in: input, options: [], range: NSRange(location: 0, length: input.utf16.count))

        for match in matches {
            guard let range = Range(match.range, in: input) else { continue }
            let url = input[range]
            print(url)
        }
    }

    var body: some View {
        ZStack {
            VStack {
                Text(data?.name ?? "loading")
                Text(data?.email ?? "loading")
                Text(data?.website ?? "loading")
            }
            closeButton
        }
//        Text(FIRclass.getOrganizationDetail(ein: ein).name)
//        Text(FIRclass.getOrganizationDetail(ein: ein).email)
//        Text(FIRclass.getOrganizationDetail(ein: ein).website)
//        Link("Visit Apple", destination: URL(string: FIRclass.getOrganizationDetail(ein: ein).website)!)
            .onAppear {
                FIRclass.getOrganizationDetail(ein: ein) { value in
                    data = value!
                    
                }
            }
    }
    
    var closeButton: some View {
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "xmark.circle")
                            .resizable()
                            .frame(width: 25, height: 25)
                            .padding(10)
                    }
                }
                .padding(.top, 5)
                Spacer()
            }
        }
}

