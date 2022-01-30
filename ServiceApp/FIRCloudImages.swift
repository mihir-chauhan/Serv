//
//  FIRCloudImages.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/29/22.
//

import Foundation
import Firebase
import SDWebImageSwiftUI
import SwiftUI

class FIRCloudImages {
    let storage = Storage.storage()
    func getRemoteImages(completion: @escaping (ConnectionResult) -> ()) {
        let storageRef = storage.reference()
        let imagesRef = storageRef.child("EventImages/civic.png")
        
        print(imagesRef.fullPath)
        
        imagesRef.downloadURL { url, error in
            if let err = error {
                completion(.failure(err.localizedDescription))
            } else {
                completion(.success(url!))
            }
        }
        
    }
}

enum ConnectionResult {
    case success(URL)
    case failure(String)
}

struct DisplayFIRImages: View {
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = URL(string: "https://via.placeholder.com/150x150.jpg")
    var body: some View {
        WebImage(url: self.placeHolderImage)
            .resizable()
            .padding()
            .aspectRatio(contentMode: .fit)
            
            .padding()
            .onAppear {
                FIRCloudImages().getRemoteImages { connectionResult in
                    switch connectionResult {
                    case .success(let url):
                        self.placeHolderImage = url
                    case .failure(let error):
                        print(error)
                    }
                }
            }
    }
}

