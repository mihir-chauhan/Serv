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
    
    @State var currentPlot = ""
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
                        
                        let minValue = incrementedValData.min() ?? 0
                        let maxValue = incrementedValData.max() ?? 1
                        let points = incrementedValData.enumerated().map { x, y in
                            CGPoint(x: CGFloat(x) * width / CGFloat(self.data.count - 1),
                                    y: (height - ((y - minValue) * height) / (maxValue - minValue)) )
                        }
                        ZStack {
                            Path { path in
                                
                                
                                path.move(to: points[0])
                                for point in points.dropFirst() {
                                    path.addLine(to: point)
                                }
                            }
                            .stroke(Color.green, lineWidth: 2)
                        }
                        .frame(width: UIScreen.main.bounds.width - 30, height: 275)

                        .overlay(
                            
                                buildIndicator()
                                    .frame(width: UIScreen.main.bounds.width - 30, height: 275)
                                    .offset(self.offset),
                                alignment: .bottomLeading
                        )
                        .frame(width: UIScreen.main.bounds.width - 30, height: 275)

                        .gesture(DragGesture()
                            .onChanged({ value in
                                withAnimation { showPlot = true }
                                let translation = value.location.x - (width / 2)
                                self.offset = CGSize(width: translation, height: 0)
                                
                                let index = max(min(Int((translation / UIScreen.main.bounds.width - 30).rounded() + 1), data.count - 1), 0)
                                
//                                if !data.isEmpty {
                                    print("AHHH", translation)
                                    currentPlot = String(format: "%.2f", data[index])
                                    self.translation = translation
                                    
//                                    offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
//                                }
                                
                            })
                                .onEnded({ value in
                                    withAnimation { showPlot = false }
                                })
                        )
                    }

                        
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
        ZStack {
        Text(currentPlot)
            .font(.caption.bold())
            .foregroundColor(Color.white)
            .padding(.vertical, 6)
            .padding(.horizontal, 10)
            .background(Color.green, in: Capsule())
        Rectangle()
            .fill(Color.green)
            .frame(width: 1, height: 45)
        
        Circle()
            .fill(Color.green)
            .frame(width: 22, height: 22)
            .overlay(
                Circle()
                    .fill(.white)
                    .frame(width: 10, height: 10)
            )
        
        Rectangle()
            .fill(Color.green)
            .frame(width: 1, height: 55)
        }
        .frame(width: UIScreen.main.bounds.width - 200)
    }
}

