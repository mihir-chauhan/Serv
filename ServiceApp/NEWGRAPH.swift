//
//  NEWGRAPH.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/10/23.
//

import Foundation
import SwiftUI


struct LineGraph2: View {
    let data: [CGFloat] = [1.0, 3.0, 7.0, 5.5]
    @State var position: CGFloat = 0.5
    
    @State var offset: CGSize = .zero
    @State var showPlot = false
    @State var translation: CGFloat = 0
    var body: some View {
        let incrementedValData: [CGFloat] = addNewValueToPrevious()
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: UIScreen.main.bounds.width - 30, height: 275)
                .foregroundColor(Color(#colorLiteral(red: 0.5294117647, green: 0.6705882353, blue: 0.9843137255, alpha: 0.25)))
                .overlay(
                    GeometryReader { geometry in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        ZStack {
                            Path { path in
                                
                                let minValue = incrementedValData.min() ?? 0
                                let maxValue = incrementedValData.max() ?? 1
                                let points = incrementedValData.enumerated().map { x, y in
                                    CGPoint(x: CGFloat(x) * width / CGFloat(self.data.count - 1),
                                            y: (height - ((y - minValue) * height) / (maxValue - minValue)) )
                                }
                                path.move(to: points[0])
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                            .stroke(Color.green, lineWidth: 2)
                        }
                        Circle()
                            .frame(width: 20, height: 20)
                            .position(x: width - 30, y: height - 30)
                            .foregroundColor(.white)
                        //                                            .background(Color.red)
                            .offset(x: -10, y: -10)
                            .opacity(0.7)
                    }

                        .gesture(DragGesture()
                            .onChanged({ value in
                                withAnimation { showPlot = true }
                                let translation = value.location.x - 40
                                
                                let index = max(min(Int((translation / UIScreen.main.bounds.width - 30).rounded() + 1), data.count - 1), 0)
                                
                                if !data.isEmpty {
                                    print("AHHH", translation)
                                    //                                   currentPlot = String(format: "%.2f", prevProgess + data[index])
                                    //                                   self.translation = translation
                                    
                                    //                                   offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
                                }
                                
                            })
                                .onEnded({ value in
                                    withAnimation { showPlot = false }
                                })
                        )
            )
        }
    }
    
    func addNewValueToPrevious() -> [CGFloat] {
        var newArray: [CGFloat] = []
        
        for (index, element) in data.enumerated() {
            if index == 0 {
                newArray.append(element)
            }
            if index > 0 {
                let previousElement = newArray[index - 1]
                let thisElement = data[index]
                let combined = previousElement + thisElement
                
                newArray.append(combined)
            }
        }
        
        print("final array ", newArray)
        return newArray
    }
    
    @ViewBuilder
    func buildIndicator() -> some View {
        Capsule()
            .frame(width: 20, height: 10)
            .offset()
    }
}

