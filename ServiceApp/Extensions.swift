//
//  Extensions.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/3/23.
//

import Foundation
import SwiftUI

// MARK: close button for custom sheetMode
struct CloseButtonSheetMode: View {
    @Binding var sheetMode: SheetMode
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    self.sheetMode = .quarter
                    
                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                    hapticResponse.impactOccurred()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(Color(.systemGray2))
                        .padding(12)
                }
            }
            .padding(.top, 5)
            Spacer()
        }
    }
}

//MARK: close button for general use
struct CloseButton: View {
    @Binding var isOpen: Bool
    var color: Color = Color(.systemGray2)
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    withAnimation(.spring()) {
                        isOpen.toggle()
                    }
                    let hapticResponse = UIImpactFeedbackGenerator(style: .soft)
                    hapticResponse.impactOccurred()
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 25, height: 25)
                        .foregroundColor(color)
                        .padding(12)
                }
            }
            .padding(.top, 5)
            Spacer()
        }
    }
}

// MARK: Phone # Formatter
extension String {
    func formattedPhoneNumber() -> String {
        let areaCode = self.prefix(3)
        let prefix = self.dropFirst(3).prefix(3)
        let lineNumber = self.dropFirst(6)
        return String(format: "(%@)-%@-%@", areaCode as CVarArg, prefix as CVarArg, lineNumber as CVarArg)
    }
}

//MARK: MONTH DAY YEAR
extension Date {
    func stringFormatted() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.string(from: self)
    }
}

extension Date {
    // converting date to String
    func dateToString(style: String = "MM/dd' 'HH:mm") -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = style
        let stringDate = dateFormatter.string(from: self)
        return stringDate
    }
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}

struct CustomMaterialEffectBlur: UIViewRepresentable {
    var blurStyle: UIBlurEffect.Style = .systemUltraThinMaterial
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: blurStyle))
    }
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurStyle)
    }
}


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }
    
    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

