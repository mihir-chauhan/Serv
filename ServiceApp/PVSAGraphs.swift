//
//  pvsaGraph.swift
//  ServiceApp
//
//  Created by Kelvin J on 8/2/22.
//
import SwiftUI
import CoreGraphics
struct PVSALineGraph: View {
    @State var hasData: Bool = false
    @State var data: [CGFloat] = [
//        0, 1.5, 0.75, 2, 6.5, 2, 2, 0, 0.85, 2.25, 2
//        989, 1200, 750, 790, 650, 25, 1200, 600, 500, 600, 890, 1203, 1400, 900, 1250, 1600, 1200
    ]
    var user: String
    var body: some View {
        LineGraph(hasData: $hasData, data: data)
            .onAppear {
                if !data.isEmpty && data.count > 1 {
                    hasData = true
                }
            }
//            .task {
//                hasData = true
//            }
//            .task {
//                FirebaseRealtimeDatabaseCRUD().getUserFriendInfo(uid: user) { friendInfo in
//                    if !friendInfo.hoursSpent.isEmpty && friendInfo.hoursSpent.count >= 1 {
//                        hasData = true
//                        data = friendInfo.hoursSpent
//
//                    }
//                }
//                FirestoreCRUD().allTimeCompleted(for: user) { totalHours in
//                    data = totalHours
//                    if !data.isEmpty && data.count >= 1 {
//                        hasData = true
//                    }
//                }
//            }
        
        
////                    } else {
////                        hasData = false
////                    }
//                }
//            }
            .cornerRadius(10)
    }
}

struct PVSABarGraph: View {
    @State var hasData: Bool = false
    @State var data: [CGFloat] = [
//        10, 13, 2, 7
    ]
    
    
    let tuple: [ (start: Date, end: Date) ]  = {
        let oneWeekBefore = Calendar.current.date(byAdding: .weekOfMonth, value: -1, to: Date().startOfWeek())
        let twoWeekBefore = Calendar.current.date(byAdding: .weekOfMonth, value: -2, to: Date().startOfWeek())
        let threeWeekBefore = Calendar.current.date(byAdding: .weekOfMonth, value: -3, to: Date().startOfWeek())
        let fourWeekBefore = Calendar.current.date(byAdding: .weekOfMonth, value: -4, to: Date().startOfWeek())
        return [
            (oneWeekBefore!, Date()),
            (twoWeekBefore!, oneWeekBefore!),
            (threeWeekBefore!, twoWeekBefore!),
            (fourWeekBefore!, threeWeekBefore!),
        ]
    }()
    var body: some View {
        BarGraph(hasData: $hasData, data: data)
            .task {
                FirestoreCRUD().serviceCompletedPerWeek(for: user_uuid!, start: tuple[0].start, end: tuple[0].end) { value1 in
                    FirestoreCRUD().serviceCompletedPerWeek(for: user_uuid!, start: tuple[1].start, end: tuple[1].end) { value2 in
                        FirestoreCRUD().serviceCompletedPerWeek(for: user_uuid!, start: tuple[2].start, end: tuple[2].end) { value3 in
                            FirestoreCRUD().serviceCompletedPerWeek(for: user_uuid!, start: tuple[3].start, end: tuple[3].end) { value4 in
                                data.append(value1 ?? 0.0)
                                data.append(value2 ?? 0.0)
                                data.append(value3 ?? 0.0)
                                data.append(value4 ?? 0.0)
                                
                                if data[0] == 0.0 && data[1] == 0.0 && data[2] == 0.0 && data[3] == 0.0 {
                                    hasData = false
                                } else {
                                    hasData = true
                                }
                            }
                        }
                    }
                }
            }
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

extension Date {
    func startOfWeek(using calendar: Calendar = .gregorian) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}


struct LineGraph: View {
    @Binding var hasData: Bool
    var data: [CGFloat]
    @State var currentPlot = ""
    @State var offset: CGSize = .zero
    @State var showPlot = false
    @State var translation: CGFloat = 0
    var body: some View {
        GeometryReader { proxy in
            let height = proxy.size.height
            let width = (proxy.size.width) / CGFloat(data.count - 1)
            
            let maxPoint = 5 + data.reduce(0, +) // getting average
            let _ = print(data.reduce(0, +))
            
            var prevProgess = 0.0
            let points = data.enumerated().compactMap { item -> CGPoint in
                print("prevProgess", prevProgess, item.element)
                let progress = (item.element + prevProgess) / maxPoint
                let pathHeight = (progress * height)
                let pathWidth = width * CGFloat(item.offset)
                prevProgess = (item.element + prevProgess)
                return CGPoint(x: pathWidth, y: -pathHeight + height)
            }
            ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
                
                Text("Hours Volunteered (All Time)")
                    .bold()
                    .padding(10)
                if hasData {
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
                    
                    if !data.isEmpty {
                        currentPlot = String(format: "%.2f", prevProgess + data[index])
                        self.translation = translation
                        
                        offset = CGSize(width: points[index].x - 40, height: points[index].y - height)
                    }
                   
                })
                    .onEnded({ value in
                        withAnimation { showPlot = false }
                    })
            )
                } else {
                    Text("Start volunteering to see progress")
                        .padding(.horizontal, 10)
                        .frame(width: UIScreen.main.bounds.width - 35, height: 250)
                }
            }
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
                       , startPoint: .top, endPoint: .bottom)
    }
}

struct BarGraph: View {
    @Binding var hasData: Bool
    @GestureState var isDragging: Bool = false
    @State var offset: CGFloat = 0
    @State var currentWeekID: CGFloat?
    var data: [CGFloat]
    var body: some View {
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .top)) {
            Text("Volunteer Hours Past 4 Weeks")
                .bold()
                .padding(10)
            if hasData {
                HStack(spacing: 10) {
                    ForEach(0..<data.count, id: \.self) { week in
                        CardView(week: week)
                            .padding(.horizontal, 10)
                            .frame(height: 250)
                            .animation(.easeOut, value: isDragging)
                            .gesture(
                                DragGesture()
                                    .updating($isDragging, body: { _, out, _ in
                                        out = true
                                    })
                                    .onChanged({ value in
                                        offset = isDragging ? value.location.x : 0
                                        
                                        let draggingSpace = UIScreen.main.bounds.width - 60
                                        let eachBlock = draggingSpace / CGFloat(data.count)
                                        let temp = Int(offset / eachBlock)
                                        
                                        print(temp)
                                        
                                        let index = max(min(temp, data.count - 1), 0)
                                        self.currentWeekID = data[index]
                                    })
                                    .onEnded({ value in
                                        offset = .zero
                                        currentWeekID = nil
                                    })
                            )
                    }
                }
            } else {
                Text("Start volunteering to see your stats")
                .padding(.horizontal, 10)
                .frame(width: UIScreen.main.bounds.width - 35, height: 250)
            }
        }
    }
    
    @ViewBuilder
    func CardView(week: Int) -> some View {
        VStack(spacing: 20) {
            GeometryReader { proxy in
                let size = proxy.size
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.mint)
                    .opacity(isDragging ? (currentWeekID == data[week] ? 1 : 0.35) : 1)
                    .frame(height: (data[week] / getMax()) * (size.height - 50))
                    .overlay(
//                      prints out element value
                        Text("\(String(format: "%.2f", Double(data[week])))")
                            .font(.callout)
                            .foregroundColor(.orange)
                            .opacity(isDragging && currentWeekID == data[week] ? 1 : 0)
                            .offset(y: -20)
                        , alignment: .top
                    )
                    .frame(maxHeight: .infinity, alignment: .bottom)
            }
//          prints out index
            Text(week == 0 ? "This Week" : week == 1 ? "Last Week" : "Week \(String(Int(week) + 1))")
                .font(.caption)
                .foregroundColor(currentWeekID == data[week] ? Color.orange : Color.gray)
        }
    }
    
    func getMax() -> CGFloat {
        let max = data.max { first, second in
            return second > first
        }
        return max ?? 0
    }
}
