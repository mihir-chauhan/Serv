//
//  AddFriendSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI

struct AddFriendSheet: View {
    
    var body: some View {
        TabView {
            Text("Your QR Code")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "qrcode")
                }
            
            
            Text("Scan a QR Code")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "qrcode.viewfinder")
                }
        }
        
    }
    
}
