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
    @Binding var data: EventInformationModel
    
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    
    var body: some View {
        ScrollView {
            
            WebImage(url: self.placeHolderImage[0])
                .resizable()
                .scaledToFill()
                .frame(maxWidth: .infinity)
                .clipped()
            
            Text(data.name)
                .font(.system(size: 30))
                .fontWeight(.bold)
                .padding()
            
            Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sit amet arcu eget magna convallis euismod non at quam. Duis vel placerat nisl.").font(.system(.caption)).padding(5)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(0..<self.placeHolderImage.count, id: \.self) { img in
                        WebImage(url: self.placeHolderImage[img])
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipped()
                    }
                }
            }.padding()
        }
        
        .onAppear {
            FIRCloudImages().getRemoteImages(gsURL: data.images!) { connectionResult in
                switch connectionResult {
                case .success(let url):
                    self.placeHolderImage.removeAll()
                    self.placeHolderImage = url
                    
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
}
