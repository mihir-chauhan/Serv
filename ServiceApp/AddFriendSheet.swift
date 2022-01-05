//
//  AddFriendSheet.swift
//  ServiceApp
//
//  Created by Mihir Chauhan on 1/2/22.
//

import SwiftUI
import CodeScanner
import AudioToolbox


struct AddFriendSheet: View {
    
    var body: some View {
//        suggest sugmented bar picker over bottom tab bar for this
        TabView {
            Image(uiImage: UIImage(data: generateQRCode(from: UUID().uuidString)!)!)
                .resizable()
                .frame(width: 290, height: 290, alignment: .center)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .tabItem {
                    Image(systemName: "qrcode")
                }
            
            
            CodeScannerView(codeTypes: [.qr], simulatedData: "fakeUUID") { response in
                switch response {
                case .success(let result):
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                    print("Found code: \(result.string)")
                    // add friend to firebase DB, when implemented.......
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
            .font(.system(size: 30, weight: .bold, design: .rounded))
            .tabItem {
                Image(systemName: "qrcode.viewfinder")
            }
        }
        
    }
    
    func generateQRCode(from string: String) -> Data? {
        let data = string.data(using: String.Encoding.ascii)
        
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 10, y: 10)
            
            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output).pngData()!
            }
        }
        
        return nil
    }
}
