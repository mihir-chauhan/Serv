//
//  FriendDetailSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/4/22.
//

import SwiftUI
import SwiftUICharts

struct FriendDetailSheet: View {
    @Binding var name: String
    @Binding var image: URL
    var body: some View {
        NavigationView {
            ScrollView {
                HStack {
                    AsyncImage(url: image) { img in
                        img
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    } placeholder: {
                        Color.gray
                    }
                        
                        .frame(width: display.width / 4)
                        .scaleEffect(1.1)
                        .clipShape(Circle())
                        .padding(.leading, 10)
                    Text("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus sit amet arcu eget magna convallis euismod non at quam. Duis vel placerat nisl.").font(.system(.caption)).padding(5)
                }
                BarChartView(data: ChartData(points: [8,13,20,12,14,17,7,13,16]), title: "Service Hours per Week", legend: "Hours", form: ChartForm.extraLarge, dropShadow: false, cornerImage: nil, animatedToBack: true).padding(10)

                PieChartView(data: [8, 23, 54, 32], title: "Service Categories", form: ChartForm.extraLarge, dropShadow: false).padding(10)

            }
            .navigationTitle(name)
        }
    }

}
