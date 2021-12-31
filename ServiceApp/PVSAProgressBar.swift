//
//  PVSAProgressBar.swift
//  ServiceApp
//
//  Created by mimi on 12/30/21.
//

import SwiftUI

struct PVSAProgressBar: View {

    var body: some View {
        VStack {
            ZStack(alignment: .leading) {
                
                  Capsule()
                    .frame(width: UIScreen.main.bounds.width - 80, height: 10)
                    .foregroundColor(Color(white: 0.8))
                  LinearGradient.horizontalDarkToLight
                    .frame(width: UIScreen.main.bounds.width - 80, height: 10)
                    .mask(Capsule())
                    .opacity(0.7)

                LinearGradient.limeGreen
                    .frame(width: 265, height: 10)
                    .mask(Capsule())
                    
            }
        }
    }
}

extension LinearGradient {
    
    static var limeGreen = LinearGradient(gradient: Gradient(colors: [Color(#colorLiteral(red: 0.6570817651, green: 1, blue: 0.5562295692, alpha: 1)), Color(#colorLiteral(red: 0.50351501, green: 0.8332892637, blue: 0.2518180663, alpha: 1))]), startPoint: .top, endPoint: .bottom)
    
    public static var diagonalDarkBorder: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [.neuWhite, .neuGray]),
        startPoint: UnitPoint(x: -0.2, y: 0.5),
        endPoint: .bottomTrailing
      )
    }
    
    public static var diagonalLightBorder: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [.neuWhite, .lightGray]),
        startPoint: UnitPoint(x: 0.2, y: 0.2),
        endPoint: .bottomTrailing
      )
    }
    
    public static var horizontalDark: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [.shadowGray, .darkGray]),
        startPoint: .leading,
        endPoint: .trailing
      )
    }
    
    public static var horizontalDarkReverse: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [.darkGray, .shadowGray]),
        startPoint: .leading,
        endPoint: .trailing
      )
    }
    
    public static var horizontalDarkToLight: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [
          .shadowGray,
          Color.white.opacity(0.0),
          .neuWhite]),
        startPoint: .top,
        endPoint: .bottom
      )
    }
    
    public static var verticalLightToDark: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [
          .neuWhite,
          Color.white.opacity(0.0),
          .shadowGray]),
        startPoint: .top,
        endPoint: .bottom
      )
    }
    
    public static var horizontalLight: LinearGradient {
      LinearGradient(
        gradient: Gradient(colors: [.neuWhite, .backgroundGray]),
        startPoint: .leading,
        endPoint: .trailing
      )
    }
    
}


extension Color {
  public static var backgroundGray: Color {
    Color(.backgroundGray)
  }
  
  public static var darkGray: Color {
    Color(.darkGray)
  }
  
  public static var shadowGray: Color {
    Color(.shadowGray)
  }
  
  public static var neuGray: Color {
    Color(.gray)
  }
  
  public static var lightGray: Color {
    Color(.lightGray)
  }
  
  public static var neuWhite: Color {
    Color(.white)
  }
}

extension UIColor {
  public class var backgroundGray: UIColor {
    UIColor(red: 0.878, green: 0.918, blue: 0.957, alpha: 1.000)
  }
  
  public class var darkGray: UIColor {
    UIColor(red: 0.192, green: 0.212, blue: 0.329, alpha: 1.000)
  }
  
  public class var shadowGray: UIColor {
    UIColor(red: 0.565, green: 0.608, blue: 0.667, alpha: 1.000)
  }
  
  public class var gray: UIColor {
    UIColor(red: 0.592, green: 0.651, blue: 0.710, alpha: 1.000)
  }
  
  public class var lightGray: UIColor {
    UIColor(red: 0.812, green: 0.851, blue: 0.890, alpha: 1.000)
  }
  
  public class var white: UIColor {
    UIColor(red: 0.929, green: 0.949, blue: 0.973, alpha: 1.000)
  }
}
