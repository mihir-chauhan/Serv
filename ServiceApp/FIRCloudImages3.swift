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
    static let cache = NSCache<NSString, NSData>()
    
    static func getRemoteImages(gsURL: String, completion: @escaping ((UIImage)?) -> ()) {
        let storageRef = storage.reference().child("EventImages")
        
        storageRef.listAll { (result, error) in
                for item in result.items {
                    item.getData(maxSize: 1 * 1024 * 1024 * 1024, completion: { data, error in
                        if let err = error {
                            fatalError(err.localizedDescription)
                        }
                        else if gsURL.contains(item.fullPath) {
                            let downloadedImage = UIImage(data: data!)
                            
                        
                            self.cache.setObject(data! as NSData, forKey: gsURL as NSString)
                            
                            completion(downloadedImage)

                        }
                    })
                
            }
        }
    }
        
    static func getImage(gsURL: String, completion: @escaping ((UIImage)?) -> ()) {
        if let imageData = cache.object(forKey: gsURL as NSString) {
            print("cached results")
            
            let image = UIImage(data: imageData as Data)
            completion(image)
        }
        else {
            getRemoteImages(gsURL: gsURL, completion: completion)
            print("loading new results")
            
//            if let all = cache.value(forKey: gsURL) as? NSArray {
//                for object in all {
//                    print("object is \(object)")
//                }
//            }
        }
    }
}
