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
    func getRemoteImages(gsURL: [String], completion: @escaping (ConnectionResult) -> ()) {
        let storageRef = storage.reference().child("EventImages")
        var tempURLArray = [URL]()
        
        var counter = 0
        
        storageRef.listAll { (result, error) in
            for item in result.items {
                print("kajsdnflanflad:    ", item.fullPath)
                item.downloadURL { url, error in
                    if let err = error {
                        completion(.failure(err.localizedDescription))
                    } else {
                        tempURLArray.append(url!)
                        counter += 1
                        if counter == result.items.count {
                            completion(.success(tempURLArray))
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
