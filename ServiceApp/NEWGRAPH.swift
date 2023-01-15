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
    
    @State var currentPlot = ""
    
    // Offset...
    @State var offset: CGSize = .zero
    
    @State var showPlot = false
    
    @State var translation: CGFloat = 0
    
    @GestureState var isDrag: Bool = false
    
    var body: some View {
        let incrementedValData: [CGFloat] = addNewValueToPrevious()

        GeometryReader{proxy in
            
            let width = proxy.size.width
            let height = proxy.size.height
            
            let minValue = incrementedValData.min() ?? 0
            let maxValue = incrementedValData.max() ?? 1
            let points = incrementedValData.enumerated().map { x, y in
                CGPoint(x: CGFloat(x) * width / CGFloat(self.data.count - 1),
                        y: (height - ((y - minValue) * height) / (maxValue - minValue)) )
            }
            
            ZStack{
                
                // Converting plot as points....
                
                // Path....
                Path{path in
                    
                    // drawing the points..
                    path.move(to: points[0])
                    for point in points.dropFirst() {
                        path.addLine(to: point)
                    }
                }
                .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .fill(
                
                    // Gradient...
                    LinearGradient(colors: [
                    
                        Color("Gradient1"),
                        Color("Gradient2"),
                    ], startPoint: .leading, endPoint: .trailing)
                )
                
                // Path Bacground Coloring...
//                FillBG()
//                    .clipShape(
//
//                        Path{path in
//
//                            // drawing the points..
//
//                            path.move(to: points[0])
//                            for point in points.dropFirst() {
//                                path.addLine(to: point)
//                            }
//                        }
//                    )
                    //.padding(.top,15)
            }
            .overlay(
            
                // Drag Indiccator...
                VStack(spacing: 0){
                    
                    Text(currentPlot)
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.vertical,6)
                        .padding(.horizontal,10)
                        .background(Color("Gradient1"),in: Capsule())
                        .offset(x: translation < 10 ? 30 : 0)
                        .offset(x: translation > (proxy.size.width - 60) ? -30 : 0)
                    
                    Rectangle()
                        .fill(Color("Gradient1"))
                        .frame(width: 1,height: 40)
                        .padding(.top)
                    
                    Circle()
                        .fill(Color("Gradient1"))
                        .frame(width: 22, height: 22)
                        .overlay(
                        
                            Circle()
                                .fill(.white)
                                .frame(width: 10, height: 10)
                        )
                    
                    Rectangle()
                        .fill(Color("Gradient1"))
                        .frame(width: 1,height: 50)
                }
                // For Gesture Calculation
                    .frame(width: 80,height: 170)
                // 170 / 2 = 85 - 15 => circle ring size
                    .offset(y: 70)
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0),
                
                alignment: .bottomLeading
            )
            .contentShape(Rectangle())
            .gesture(DragGesture().onChanged({ value in
                
                withAnimation{showPlot = true}
                
                let translation = value.location.x
                
                // Getting index
                #error("this line is what's causing the line graph drag indicator to not work as expected")
                let index = max(min(Int((translation / width).rounded() + 1), incrementedValData.count - 1), 0)
//                let index = (max(0 , 4))
                print(incrementedValData[index])
                currentPlot = "\(incrementedValData[index])"
                self.translation = translation
                
                // removing half width
                offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
                
            }).onEnded({ value in
                
                withAnimation{showPlot = false}
                
            }).updating($isDrag, body: { value, out, _ in
                out = true
            }))
        }
        .background(
        
            VStack(alignment: .leading){
                
                let max = incrementedValData.max() ?? 0
                
                Text("\(Int(max)) hrs")
                    .font(.caption.bold())
                    .offset(y: -5)
                
                Spacer()
                
                Text("0 hr")
                    .font(.caption.bold())
                    .offset(y: 10)
            }
            .frame(maxWidth: .infinity,alignment: .leading)
        )
        .padding(.horizontal,10)
        .onChange(of: isDrag) { newValue in
            if !isDrag{showPlot = false}
        }
        
        
        .frame(height: 220)
        .padding(.top,25)
    }
    
    @ViewBuilder
    func FillBG()->some View{
        LinearGradient(colors: [
        
            Color("Gradient2")
                .opacity(0.3),
            Color("Gradient2")
                .opacity(0.2),
            Color("Gradient2")
                .opacity(0.1)]
            + Array(repeating:                     Color("Gradient1")
                .opacity(0.1), count: 4)
            + Array(repeating:                     Color.clear, count: 2)
            , startPoint: .top, endPoint: .bottom)
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
}
