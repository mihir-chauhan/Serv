//
//  pvsaGraph.swift
//  ServiceApp
//
//  Created by Kelvin J on 8/2/22.
//

import SwiftUI

struct PVSAGraph: View {
    var data: [CGFloat] = [
        0, 1.5, 0.75, 2, 6.5, 2, 2, 0, 0.85, 2.25, 2
//        989, 1200, 750, 790, 650, 25, 1200, 600, 500, 600, 890, 1203, 1400, 900, 1250, 1600, 1200
    ]
    var body: some View {
        LineGraph(data: data)
            
            .cornerRadius(20)
    }
}


struct LineGraph: View {
    var data: [CGFloat]
    @State var currentPlot = ""
    @State var offset: CGSize = .zero
    @State var showPlot = false
    @State var translation: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = (proxy.size.width) / CGFloat(data.count - 1)
            
            let maxPoint = (data.max() ?? 0) + (data.reduce(0, +) / CGFloat(data.count)) // getting average
            let _ = print(data.reduce(0, +))
            
            let points = data.enumerated().compactMap { item -> CGPoint in
                let progress = item.element / maxPoint
                let pathHeight = (progress * height)
                let pathWidth = width * CGFloat(item.offset)
//                if  {
//                    pathWidth
//                    print(points[currentIndex - 1], "Previously...", points[currentIndex - 1])
//                }

                return CGPoint(x: pathWidth, y: -pathHeight + height)
            }
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: 0))
                    path.addLines(points)
                }
                .strokedPath(StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round))
                .fill(
                    LinearGradient(colors: [
                        Color.mint,
                        Color.purple
                    ], startPoint: .leading, endPoint: .trailing)
                )
                
                fillBG()
                .clipShape(
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLines(points)
                        path.addLine(to: CGPoint(x: proxy.size.width, y: height))
                        path.addLine(to: CGPoint(x: 0, y: height))
                    }
                )
                Text("Hours Volunteered per Month")
                    .bold()
                    .padding()
            }
            .overlay (
                //Drag
                VStack(spacing: 0) {
                    Text("\(String(currentPlot))")
                        .font(.caption.bold())
                        .foregroundColor(.white)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 10)
                        .background(Color.blue, in: Capsule())
                        .offset(x: translation < 10 ? 30 : 0)
                        .offset(x: translation > (proxy.size.width - 60) ? -30 : 0)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 1, height: 5)
                        .padding(.top, 2.5)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 22, height: 22)
                        .overlay(
                        Circle()
                            .fill(.white)
                            .frame(width: 10, height: 10)
                        )
                Rectangle()
                        .fill(Color.blue)
                        .frame(width: 1, height: 35)
                }
                    .frame(width: 80, height: 170)
                    .offset(y: 85)
                    .offset(offset)
                    .opacity(showPlot ? 1 : 0),
                alignment: .bottomLeading
            )
            .contentShape(Rectangle())
            .gesture(DragGesture()
                .onChanged({ value in
                    withAnimation { showPlot = true }
                    let translation = value.location.x - 40
                    
                    let index = max(min(Int((translation / width).rounded() + 1), data.count - 1), 0)
                    

                    currentPlot = "\(data[index])"
                    self.translation = translation
                    
                    offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
                })
                    .onEnded({ value in
                        withAnimation { showPlot = false }
                    })
            )
        }.frame(height: 250)
    }
    
    @ViewBuilder
    func fillBG() -> some View {
        LinearGradient(colors: [
            Color.blue
                .opacity(0.3),
            Color.purple
                .opacity(0.2),
            Color.orange
                .opacity(0.1)
            
        ]
//                               + Array(repeating: Color.brown.opacity(0.1), count: 4)
//                               + Array(repeating: Color.clear, count: 2)
                       
                       , startPoint: .top, endPoint: .bottom)
    }
}
