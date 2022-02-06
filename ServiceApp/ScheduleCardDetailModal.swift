//
//  FriendDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI
import SwiftUICharts
import SDWebImageSwiftUI

struct ScheduleCardDetailSheet: View {
    var name: String
    
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]

    var body: some View {
        NavigationView {
            ScrollView {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(0..<self.placeHolderImage.count, id: \.self) { img in
                            WebImage(url: self.placeHolderImage[img])
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 150, height: 150)
                        }
                    }
                }
                Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sit amet arcu eget magna convallis euismod non at quam. Duis vel placerat nisl.").font(.system(.caption)).padding(5)
            }
            .navigationTitle(name)
        }
        .onAppear {
//            FIRCloudImages().getRemoteImages(gsURL: data.images) { connectionResult in
//                switch connectionResult {
//                case .success(let url):
//                    self.placeHolderImage.removeAll()
//                    self.placeHolderImage = url
//
//                case .failure(let error):
//                    print(error)
//                }
//            }
        }
    }
}
