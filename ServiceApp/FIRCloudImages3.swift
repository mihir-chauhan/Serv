//
//  FIRCloudImages2.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/5/22.
//

import Firebase
import UIKit
import SwiftUI

class FIRCloudImages3 {
    static let storage = Storage.storage()
    static let cache = NSCache<NSString, UIImage>()
    
    static func getRemoteImages(gsURL: String, completion: @escaping ((UIImage)?) -> ()) {
        let storageRef = storage.reference().child("EventImages")
        
        storageRef.listAll { (result, error) in
                for item in result.items {
                    //                        get image then convert to data for cache use existing
                    
                    item.getData(maxSize: 1 * 1024 * 1024 * 1024, completion: { data, error in
                        if let err = error {
                            fatalError(err.localizedDescription)
                        }
                        else if gsURL.contains(item.fullPath) {
                            let downloadedImage = UIImage(data: data!)
                            
                            if downloadedImage != nil {
                                self.cache.setObject(downloadedImage!, forKey: gsURL as NSString)
                            }
//                            if let image = self.cache.object(forKey: gsURL as NSString) {
//                                print("CACHEDDD")
//                            }
                            completion(downloadedImage)

                        }
                    })
                
            }
        }
    }
        
    static func getImage(gsURL: String, completion: @escaping ((UIImage)?) -> ()) {
        if let image = cache.object(forKey: gsURL as NSString) {
            print("cached results")
            completion(image)
        }
        else {
            getRemoteImages(gsURL: gsURL, completion: completion)
            print("loading new results")
        }
    }
}
