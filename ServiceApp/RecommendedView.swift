//
//  RecommendedView.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/1/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecommendedView: View {
    @State var placeHolderImage = URL(string: "https://via.placeholder.com/150x150.jpg")
    var data: EventInformationModel
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 180, height: 250)
                .foregroundColor(Color(#colorLiteral(red: 0.9688304554, green: 0.9519491526, blue: 0.8814709677, alpha: 1)))
            WebImage(url: self.placeHolderImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 145)
                .background(Color(.systemGray4))
                .cornerRadius(20)
                
                .onAppear {
                    FIRCloudImages().getRemoteImages { connectionResult in
                        switch connectionResult {
                        case .success(let url):
                            self.placeHolderImage = url[0]
                            print(url)
                        case .failure(let error):
                            print(error)
                        }
                    }
                }
        }    }
}


