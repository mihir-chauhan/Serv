//
//  FIRCloudImages.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/29/22.
//

import Foundation
import SwiftUI

class PhotoFileManager {
    func documentDirectoryPath() -> URL? {
        let path = FileManager.default.urls(for: .documentDirectory,
                                            in: .userDomainMask)
        return path.first
    }
    func savePng(_ image: UIImage) {
        if let pngData = image.pngData(),
            let path = documentDirectoryPath()?.appendingPathComponent("examplePng.png") {
            try? pngData.write(to: path)
        }
    }
    func saveJpg(_ image: UIImage, fileName: String) {
        if let jpgData = image.jpegData(compressionQuality: 0.2),
            let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).jpg") {
            try? jpgData.write(to: path)
//            try? FileManager.default.createFile(atPath: path.path, contents: jpgData, attributes: [.init(rawValue: ""): <#value#>])
            
            
        }
    }
    
    public func getImage(fileName: String) -> UIImage? {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)

        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let imagePath = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(fileName).jpg").path
            
            let attributes = try? FileManager.default.attributesOfItem(atPath: imagePath)
            let creationDate = attributes?[.creationDate]
            print("Creation Date: ", creationDate)
            
            
            return UIImage(contentsOfFile: imagePath)
        }
        return nil
    }
    
    func deleteJpg(for file: String) {
//        if the event is past the Date(), delete the file
    }
}




