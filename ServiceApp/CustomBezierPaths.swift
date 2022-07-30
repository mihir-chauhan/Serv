//
//  CustomBezierPaths.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/12/22.
//

import SwiftUI

struct CustomBezierPaths: View {
    var body: some View {
        ScaledBezier(bezierPath: .attempt1)
            .stroke(lineWidth: 2)
            .frame(width: 200, height: 200)
    }
}

struct CustomBezierPaths_Previews: PreviewProvider {
    static var previews: some View {
        CustomBezierPaths()
    }
}

struct ScaledBezier: Shape {
    let bezierPath: UIBezierPath
    
    func path(in rect: CGRect) -> Path {
//        let path = Path(bezierPath.cgPath)
//
//        let multipler = min(rect.width, rect.height)
//        let transform = CGAffineTransform(scaleX: multipler, y: multipler)
//        return path.applying(transform)
        return Path(bezierPath.cgPath)
    }
}

extension UIBezierPath {
    /// The Unwrap logo as a Bezier path.
    static var logo: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.534, y: 0.5816))
        path.addCurve(to: CGPoint(x: 0.1877, y: 0.088), controlPoint1: CGPoint(x: 0.534, y: 0.5816), controlPoint2: CGPoint(x: 0.2529, y: 0.4205))
        path.addCurve(to: CGPoint(x: 0.9728, y: 0.8259), controlPoint1: CGPoint(x: 0.4922, y: 0.4949), controlPoint2: CGPoint(x: 1.0968, y: 0.4148))
        path.addCurve(to: CGPoint(x: 0.0397, y: 0.5431), controlPoint1: CGPoint(x: 0.7118, y: 0.5248), controlPoint2: CGPoint(x: 0.3329, y: 0.7442))
        path.addCurve(to: CGPoint(x: 0.6211, y: 0.0279), controlPoint1: CGPoint(x: 0.508, y: 1.1956), controlPoint2: CGPoint(x: 1.3042, y: 0.5345))
        path.addCurve(to: CGPoint(x: 0.6904, y: 0.3615), controlPoint1: CGPoint(x: 0.7282, y: 0.2481), controlPoint2: CGPoint(x: 0.6904, y: 0.3615))
        return path
    }
    
    static var i: UIBezierPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0.50, y: 0.10))
        path.addLine(to: CGPoint(x: 0.6, y: -0.90))
        path.addArc(withCenter: CGPoint(x: 0.1, y: -0.7), radius: 40, startAngle: CGFloat(Double.pi/2 * 3), endAngle: 0, clockwise: true)
//        path.addCurve(to: CGPoint(x: 0.23, y: 0.85), controlPoint1: CGPoint(x: 0.534, y: 0.5816), controlPoint2: CGPoint(x: 0.2529, y: 0.4205))
        return path
    }
    
    static var attempt1: UIBezierPath {
        let bezierPath = UIBezierPath()
        bezierPath.move(to: CGPoint(x: 170.5, y: 25.5))
        bezierPath.addCurve(to: CGPoint(x: 103.5, y: 40.5), controlPoint1: CGPoint(x: 169.5, y: 33.5), controlPoint2: CGPoint(x: 120.25, y: 36.75))
        bezierPath.addCurve(to: CGPoint(x: 75.5, y: 77.5), controlPoint1: CGPoint(x: 86.75, y: 44.25), controlPoint2: CGPoint(x: 82.5, y: 68.25))
        bezierPath.addCurve(to: CGPoint(x: 63.5, y: 84.5), controlPoint1: CGPoint(x: 68.5, y: 86.75), controlPoint2: CGPoint(x: 63.5, y: 84.5))
        UIColor.black.setStroke()
        bezierPath.lineWidth = 1
        bezierPath.stroke()
        return bezierPath
    }
}
