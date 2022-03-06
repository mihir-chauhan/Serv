//
//  FIRCloudImages2.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/5/22.
//

import Firebase
import UIKit

class FIRCloudImages3: ObservableObject {
    static let storage = Storage.storage()
    static func listAllImages(completion: @escaping (ConnectionResult) -> ()) {
        var counter = 0
        let storageRef = storage.reference().child("EventImages")
        var tempURLArray = [URL]()
        storageRef.listAll { (result, error) in
            for item in result.items {
                item.downloadURL { url, error in
                    if let _ = error { }
                    else {
                        tempURLArray.append(url!)
                        print("A", "\(item.root())\(item.fullPath)")
                        counter += 1
                        if counter == result.items.count {
                            completion(.success(tempURLArray))
                            
                        }
                    }
                }
            }
        }
    }
    
     static func getRemoteImages(gsURL: String, completion: @escaping (_ image: UIImage?) -> ()) {
//        caching image data
        let request = URLRequest(url: gsURL, cachePolicy: .returnCacheDataElseLoad)
        let dataTask = URLSession.shared.dataTask(with: request) { (data, url, error) in
            var downloadedImage: UIImage?
            
            if let error = error {
                print(error.localizedDescription)
            }
            
            else if let data = data {
                downloadedImage = UIImage(data: data)
            }
            
            DispatchQueue.main.async {
                completion(downloadedImage)
            }
        }
        dataTask.resume()
    }
}

func perform() {
//    for i in all images in storage bucket {
//    perform each query by using the function w the given url as parameter
}


enum FIRURLRESULT {
    
}
