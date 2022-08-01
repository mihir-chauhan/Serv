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
    @EnvironmentObject var viewModel: AuthViewModel
    @State var showPhotoPicker = false
    @State var selectedImage: UIImage? = nil
    
    @State var showingAlert: Bool = false
    @State var showingAlreadyFriendAlert: Bool = false
    @State var showSuccess: Bool = false
    var body: some View {
        NavigationView {
            if #available(iOS 15.0, *) {
                TabView {
//                    Image(uiImage: UIImage(data: generateQRCode(from: (viewModel.decodeUserInfo()?.uid!)!)!)!)
                    //                        .resizable()
                    //                        .frame(width: 290, height: 290, alignment: .center)
                    //                        .font(.system(size: 30, weight: .bold, design: .rounded))
                    //                        .tabItem {
                    //                            Image(systemName: "qrcode")
                    //                        }
                    //                        .tag(0)
                    ZStack {
                        if selectedImage == nil {
                            ZStack {
                                CodeScannerView(codeTypes: [.qr], simulatedData: "fakeUUID") { response in
                                    switch response {
                                    case .success(let result):
                                        FirebaseRealtimeDatabaseCRUD().checkIfUserExists(uuidString: result.string) { value in
                                            if value == true {
                                                FirebaseRealtimeDatabaseCRUD().readFriends(for: (viewModel.decodeUserInfo()?.uid)!) { friendsArray in
                                                    FirebaseRealtimeDatabaseCRUD().writeFriends(for: (viewModel.decodeUserInfo()?.uid)!, friendUUID: result.string)
                                                    FirebaseRealtimeDatabaseCRUD().writeFriends(for: result.string, friendUUID: (viewModel.decodeUserInfo()?.uid)!)
                                                    showSuccess = true
                                                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
                                                }
                                            }
                                        }
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
                        if showSuccess {
                            ConfirmNewFriendView(show: $showSuccess)
                        }
                    }.tabItem {
                        Image(systemName: "qrcode.viewfinder")
                    }
                }
                
                .alert("Friend Already Exists!", isPresented: $showingAlreadyFriendAlert) {
                    Button("OK", role: .cancel) {
                    }
                }
                
                .alert("QR Code is Invalid!", isPresented: $showingAlert) {
                    Button("OK", role: .cancel) {
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
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    private func generateQRCode(from string: String) -> Data? {
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
