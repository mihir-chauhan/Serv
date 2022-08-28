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
                item.getData(maxSize: 1 * 512 * 512 * 512, completion: { data, error in
                    if let err = error {
                        print(err.localizedDescription)
                        return
                    }
                    else if gsURL.contains(item.fullPath) {
                        print("item.fullPath ", item.fullPath)
                        let downloadedImage = UIImage(data: data!)
                        PhotoFileManager().saveJpg(UIImage(data: data!)!, fileName: gsURL.replacingOccurrences(of: "gs://serviceapp22.appspot.com/EventImages/", with: "").replacingOccurrences(of: ".jpg", with: ""), eventDate: eventDate)
                        completion(downloadedImage)
                        
                    }
                })
                
            }
        }
        completion(UIImage())
    }
    
    static func getImage(gsURL: String, eventID: String, eventDate: Date, completion: @escaping ((UIImage)?) -> ()) {
        if let image = PhotoFileManager().getImage(fileName: gsURL.replacingOccurrences(of: "gs://serviceapp22.appspot.com/EventImages/", with: "").replacingOccurrences(of: ".jpg", with: "")) {
            print("used saved img at: ", image)
            completion(image)
        }
        else {
            getRemoteImages(gsURL: gsURL, eventID: eventID, eventDate: eventDate, completion: completion)
            print("loading new results")
        }
    }
    
    func uploadPfp(uid: String, viewModel: AuthViewModel, for image: UIImage) {
        let db = Firestore.firestore()
        let storageRef = FIRCloudImages.storage.reference().child("ProfilePictures")
        let profilePicRef = storageRef.child("\(String(describing: viewModel.decodeUserInfo()!.uid!))")
        
        //compression2:
        let myImage = image.resizeWithWidth(width: 100)
        let compressedData = myImage?.jpegData(compressionQuality: 0.5)
        
        
        profilePicRef.putData(compressedData!, metadata: nil) { (metadata, error) in
            guard let metadata = metadata else {
                return
            }
            let size = metadata.size
            print("size", size)
            //            }
        }
        profilePicRef.downloadURL { (url, error) in
            guard let downloadURL = url else {
                return
            }
            let dbRef = db.collection("Volunteer Accounts").document(viewModel.decodeUserInfo()!.uid!)
            
            dbRef.updateData([
                "UserInfo.photoURL" : downloadURL.absoluteString
            ])
            let oldStuff = viewModel.decodeUserInfo()!
            viewModel.encodeUserInfo(for: UserInfoFromAuth(
                uid: oldStuff.uid, displayName: oldStuff.displayName, username: "no username", photoURL: downloadURL, email: oldStuff.email, bio: oldStuff.bio
            ))
            //            TODO: must update userinfo user defaults
            print("HERE", downloadURL.absoluteString)
            
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
    func compressImage(image: UIImage) -> Data? {
        let resizedImage = image.aspectFittedToHeight(200)
        resizedImage.jpegData(compressionQuality: 0.2)
        return resizedImage.pngData()
    }
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}
