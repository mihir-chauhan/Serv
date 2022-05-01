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

class FIRCloudImagesUSED {
    let storage = Storage.storage()
    func getRemoteImages(gsURL: [String], completion: @escaping (ConnectionResult) -> ()) {
        let storageRef = storage.reference().child("EventImages")
        var tempURLArray = [URL]()
        
        var counter = 0
        
        storageRef.listAll { (result, error) in
            for i in 0...(gsURL.count-1) {
                for item in result.items {
                    item.downloadURL { url, error in
                        if let err = error {
                            completion(.failure(err.localizedDescription))
                        } else if gsURL[i].contains(item.fullPath) {
                            tempURLArray.append(url!)
                            counter += 1
                            if counter == gsURL.count {
                                completion(.success(tempURLArray))
                            }
                        }
                    }
                }
            }
        }
    }
}

enum ConnectionResult {
    case success([URL])
    case failure(String)
}
