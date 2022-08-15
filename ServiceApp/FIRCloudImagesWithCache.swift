//
//  FIRCloudImages2.swift
//  ServiceApp
//
//  Created by Kelvin J on 3/5/22.
//

import Firebase
import UIKit
import SwiftUI
import FirebaseAuth
import AuthenticationServices

//By declaring properties and methods as Static, Swift allocates them directly into the object's memory, making it available for use without the need of an instance

class FIRCloudImages {
    static let storage = Storage.storage()
//    static let cache = NSCache<NSString, NSData>()
    
    static func getRemoteImages(gsURL: String, eventID: String, eventDate: Date, completion: @escaping ((UIImage)?) -> ()) {
        let storageRef = storage.reference().child("EventImages")
        
        storageRef.listAll { (result, error) in
                for item in result.items {
                    item.getData(maxSize: 1 * 1024 * 1024 * 1024, completion: { data, error in
                        if let err = error {
                            print(err.localizedDescription)
                            return
                        }
                        else if gsURL.contains(item.fullPath) {
                            print("GSURL ", gsURL)
                            print("item.fullPath ", item.fullPath)
                            let downloadedImage = UIImage(data: data!)
                            
                            PhotoFileManager().saveJpg(UIImage(data: data!)!, fileName: eventID, eventDate: eventDate)
                            
//                            self.cache.setObject(data! as NSData, forKey: gsURL as NSString)

                            completion(downloadedImage)

                        }
                    })

            }
        }
        completion(UIImage())
    }
        
    static func getImage(gsURL: String, eventID: String, eventDate: Date, completion: @escaping ((UIImage)?) -> ()) {

        
        if let image = PhotoFileManager().getImage(fileName: eventID) {
            print("used saved img at: ", image.jpegData(compressionQuality: 0.2))
            completion(image)
        }
        else {
        getRemoteImages(gsURL: gsURL, eventID: eventID, eventDate: eventDate, completion: completion)
            print("loading new results")
        }
    }
    
    func uploadPfp(uid: String, viewModel: AuthViewModel, for data: Data) {
        let db = Firestore.firestore()
        let storageRef = FIRCloudImages.storage.reference().child("ProfilePictures")
        let profilePicRef = storageRef.child("\(String(describing: viewModel.decodeUserInfo()!.uid!))")
        profilePicRef.putData(data, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let size = metadata.size
            print("size", size)
        }
        profilePicRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                return
            }
            let dbRef = db.collection("Volunteer Accounts").document(viewModel.decodeUserInfo()!.uid!)
            
            dbRef.updateData([
                "UserInfo.photoURL" : downloadURL.absoluteString
            ])
//            let changeReq = Auth.auth().currentUser?.createProfileChangeRequest()
//            changeReq?.photoURL = downloadURL
//            changeReq?.commitChanges { error in
//                if error == nil {
//                    // Do something
//                } else {
//                    // Do something
//                }
//            }
            let oldStuff = viewModel.decodeUserInfo()!
            viewModel.encodeUserInfo(for: UserInfoFromAuth(
                uid: oldStuff.uid, displayName: oldStuff.displayName, username: "no username", photoURL: downloadURL, email: oldStuff.email, bio: oldStuff.bio
            ))
//            TODO: must update userinfo user defaults
            print("HERE", downloadURL.absoluteString)
            
        }
    }
}

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

//Compressing image size
extension UIImage {
    enum JPEGQuality: CGFloat {
        case lowest = 0
        case low = 0.25
        case medium = 0.5
        case high = 0.75
        case highest = 1
    }
    
    func jpeg(_ jpegQuality: JPEGQuality) -> Data? {
        return jpegData(compressionQuality: jpegQuality.rawValue)
    }
}

extension UIImage {
    func aspectFittedToHeight(_ newHeight: CGFloat) -> UIImage {
        let scale = newHeight / self.size.height
        let newWidth = self.size.width * scale
        let newSize = CGSize(width: newWidth, height: newHeight)
        let renderer = UIGraphicsImageRenderer(size: newSize)

        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    func compressImage(image: UIImage) -> UIImage {
            let resizedImage = image.aspectFittedToHeight(200)
            resizedImage.jpegData(compressionQuality: 0.2)
            return resizedImage
    }
}
