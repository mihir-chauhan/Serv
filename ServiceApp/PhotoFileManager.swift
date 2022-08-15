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
    func saveJpg(_ image: UIImage, fileName: String, eventDate: Date) {
        // convert Date --> Timestamp --> Data
        let timestamp = eventDate.timeIntervalSinceReferenceDate
        let dateAsData = withUnsafeBytes(of: timestamp) { Data($0) }
        print("\(dateAsData) - \(dateAsData.map { String(format: "$02hhx", $0) }.joined())")
        
        
        if let jpgData = image.jpegData(compressionQuality: 0.2),
            let path = documentDirectoryPath()?.appendingPathComponent("\(fileName).jpg") {
            try? jpgData.write(to: path)
            
            //adding custom metadata
            let attr1 = "dateOfEvent"
            try? path.setExtendedAttribute(data: dateAsData, forName: attr1)
        }
    }
    
    public func getImage(fileName: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let imagePath = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(fileName).jpg")
            
//            let attributes = try? FileManager.default.attributesOfItem(atPath: imagePath)
//            let creationDate = attributes?[.creationDate]
//            print("Creation Date: ", creationDate)
            //get custom metadata:
            let customMetadata = try? imagePath.extendedAttribute(forName: "dateOfEvent")
            let retrievedTimestamp = customMetadata?.withUnsafeBytes { $0.load(as: Double.self) }
            print(retrievedTimestamp)
            let retrievedDate = Date(timeIntervalSinceReferenceDate: retrievedTimestamp ?? 0)
            print("DATE OF EVENT", retrievedDate)
            
            return UIImage(contentsOfFile: imagePath.path)
        }
        return nil
    }
    
    func deleteJpg(for fileName: String) {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            let imagePath = URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("\(fileName).jpg")
            
            try? FileManager.default.removeItem(at: imagePath)
            print("Item deleted")
        }
        
    }
}

extension URL {

    /// Get extended attribute.
    func extendedAttribute(forName name: String) throws -> Data  {

        let data = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> Data in

            // Determine attribute size:
            let length = getxattr(fileSystemPath, name, nil, 0, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var data = Data(count: length)

            // Retrieve attribute:
            let result =  data.withUnsafeMutableBytes { [count = data.count] in
                getxattr(fileSystemPath, name, $0.baseAddress, count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
            return data
        }
        return data
    }

    /// Set extended attribute.
    func setExtendedAttribute(data: Data, forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = data.withUnsafeBytes {
                setxattr(fileSystemPath, name, $0.baseAddress, data.count, 0, 0)
            }
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Remove extended attribute.
    func removeExtendedAttribute(forName name: String) throws {

        try self.withUnsafeFileSystemRepresentation { fileSystemPath in
            let result = removexattr(fileSystemPath, name, 0)
            guard result >= 0 else { throw URL.posixError(errno) }
        }
    }

    /// Get list of all extended attributes.
    func listExtendedAttributes() throws -> [String] {

        let list = try self.withUnsafeFileSystemRepresentation { fileSystemPath -> [String] in
            let length = listxattr(fileSystemPath, nil, 0, 0)
            guard length >= 0 else { throw URL.posixError(errno) }

            // Create buffer with required size:
            var namebuf = Array<CChar>(repeating: 0, count: length)

            // Retrieve attribute list:
            let result = listxattr(fileSystemPath, &namebuf, namebuf.count, 0)
            guard result >= 0 else { throw URL.posixError(errno) }

            // Extract attribute names:
            let list = namebuf.split(separator: 0).compactMap {
                $0.withUnsafeBufferPointer {
                    $0.withMemoryRebound(to: UInt8.self) {
                        String(bytes: $0, encoding: .utf8)
                    }
                }
            }
            return list
        }
        return list
    }

    /// Helper function to create an NSError from a Unix errno.
    private static func posixError(_ err: Int32) -> NSError {
        return NSError(domain: NSPOSIXErrorDomain, code: Int(err),
                       userInfo: [NSLocalizedDescriptionKey: String(cString: strerror(err))])
    }
}
