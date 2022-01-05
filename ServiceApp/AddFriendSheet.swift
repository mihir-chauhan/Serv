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
    @State var showPhotoPicker = false
    @State var selectedImage: UIImage? = nil
    var body: some View {
        NavigationView {
            TabView {
                Image(uiImage: UIImage(data: generateQRCode(from: UUID().uuidString)!)!)
                    .resizable()
                    .frame(width: 290, height: 290, alignment: .center)
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .tabItem {
                        Image(systemName: "qrcode")
                    }
                ZStack {
                    if selectedImage == nil {
                        ZStack {
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
                        }.font(.system(size: 30, weight: .bold, design: .rounded))
                    } else {
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .padding()
                        }
                    }
                }.tabItem {
                    Image(systemName: "qrcode.viewfinder")
                }
            }
            
            .fullScreenCover(isPresented: $showPhotoPicker) {
                PhotoPicker() { results in
                    PhotoPicker.convertToUIImageArray(fromResults: results) { imageOrNil, errorOrNil in
                        if let error = errorOrNil {
                            print(error)
                        }
                        if let images = imageOrNil {
                            selectedImage = images.first
                            if let features = readQRCodeFromImage(images.first) {
                                for case let row as CIQRCodeFeature in features {
                                    // add friend to firebase DB, when implemented.......
                                    print(row.messageString ?? "no result")
                                }
                            }
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showPhotoPicker.toggle() }) {
                        Text("Choose Photo...")
                    }
                }
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
    
    func readQRCodeFromImage(_ image: UIImage?) -> [CIFeature]?  {
        guard let image = image, let ciImage = CIImage.init(image: image) else { return nil }
        var options: [String : Any]
        let context = CIContext()
        options = [CIDetectorAccuracy : CIDetectorAccuracyHigh]
        let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
        if ciImage.properties.keys.contains(kCGImagePropertyOrientation as String) {
            options = [CIDetectorImageOrientation : ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
        } else {
            options = [CIDetectorImageOrientation : 1]
        }
        let features = qrDetector?.features(in: ciImage, options: options)
        return features
    }
}
