//
//  Experimental .swift
//  ServiceApp
//
//  Created by Kelvin J on 1/29/22.
//

import Foundation

import Firebase
import SDWebImageSwiftUI
import SwiftUI

class FIRCloudImages2 {
//    @Published
    let storage = Storage.storage()
    func getRemoteImages(completion: @escaping (ConnectionResult) -> ()) {
        let storageRef = storage.reference().child("EventImages")
//        let group = DispatchGroup()
        var imageURLArray = [URL]()

//        For querying multiple images
        let items = storageRef.listAll { result, err in
            if let err = err {
                print(err.localizedDescription)
            }
            for item in result.items {
                item.downloadURL { url, error in
                    if let err = error {
                        completion(.failure(err.localizedDescription))
                    } else {
                        imageURLArray.append(url!)
//                        print(url!)
                        
                    }
                }
            }
//            completion(.success(items))
            
        }
        

//         For querying one image
//        storageRef.downloadURL { url, error in
//            if let err = error {
//                completion(.failure(err.localizedDescription))
//            } else {
//                completion(.success(url!))
//            }
//        }
        
    }
}

struct DisplayFIRImages2: View {
    var connectionResult = ConnectionResult.failure("OK!")
    @State var placeHolderImage = [URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/4/49/A_black_image.jpg/640px-A_black_image.jpg")]
    var body: some View {
        WebImage(url: self.placeHolderImage[0])
            .resizable()
            .padding()
            .aspectRatio(contentMode: .fit)
            
            .padding()
            .onAppear {
                FIRCloudImages2().getRemoteImages { connectionResult in
                    switch connectionResult {
                    case .success(let url):
                        self.placeHolderImage.removeAll()
//                        self.placeHolderImage = url
//                        self.placeHolderImage = url
                    case .failure(let error):
                        print(error)
                    }
                }
            }
    }
}
