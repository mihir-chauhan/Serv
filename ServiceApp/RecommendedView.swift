//
//  RecommendedView.swift
//  ServiceApp
//
//  Created by Kelvin J on 2/1/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct RecommendedView: View {
    @EnvironmentObject var sheetObserver: SheetObserver
    @State var placeHolderImage = URL(string: "https://via.placeholder.com/150x150.jpg")
    var data: EventInformationModel
    var dateToString: String {
        get {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyy"
            let stringDate = dateFormatter.string(from: data.time)
            return stringDate
        }
    }
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .center, vertical: .top)) {
            RoundedRectangle(cornerRadius: 20)
                
                .foregroundColor(Color(#colorLiteral(red: 0.9688304554, green: 0.9519491526, blue: 0.8814709677, alpha: 1)))
            VStack(alignment: .leading) {
                WebImage(url: self.placeHolderImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 180, height: 145)
                    .background(Color(.systemGray4))
                    .cornerRadius(20)
                Text(data.name)
                    .font(.headline)
                    .padding(15)
                    
                Spacer()
                HStack {
                    Text(data.category)
                        .font(.caption)
                        .bold()
                        .foregroundColor(Color.gray)
                    Spacer()
                    Text(self.dateToString)
                        .font(.system(size: 10))
                        .font(.caption2)
                        .foregroundColor(Color.gray)
                }.padding(15)
            }
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
        }.frame(width: 180, height: 250)
            .onTapGesture {
                
                self.sheetObserver.sheetMode = .half
                EventDetailView(data: self.sheetObserver.eventDetailData, sheetMode: self.$sheetObserver.sheetMode)
            }
    }
}




