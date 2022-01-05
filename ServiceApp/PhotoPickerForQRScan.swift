//
//  PhotoPickerForQRScan.swift
//  ServiceApp
//
//  Created by Kelvin J on 1/4/22.
//

import SwiftUI
import PhotosUI

struct PhotoPicker: View {
    @State var showPhotoPicker = false
    @State var selectedImage: UIImage? = nil
    var body: some View {
        Button(action: { showPhotoPicker = true }) {
            Label("Choose photo", systemImage: "photo.fill")
                .fullScreenCover(isPresented: $showPhotoPicker) {
                    // Create the picker. We only want to allow the user to select a single image.
                    // We ignore the safe area so that the picker takes up the entire screen when open.
                    PhotoPickerView() { results in
                        PhotoPickerView.convertToUIImageArray(fromResults: results) { imagesOrNil, errorOrNil in
                            if let error = errorOrNil {
                                print(error)
                            }
                            if let images = imagesOrNil {
                                if let first = images.first {
                                    selectedImage = first
                                }
                            }
                        }
                    }
                        .edgesIgnoringSafeArea(.all)
                }
            
            if let image = selectedImage {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: 200, maxHeight: 200)
            }
        }
    }
}

struct PhotoPickerView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PHPickerViewController
    let filter: PHPickerFilter = .images
    var limit: Int = 1
    
    let onComplete: ([PHPickerResult]) -> Void
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = filter
        configuration.selectionLimit = limit
        
        let controller = PHPickerViewController(configuration: configuration)
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) { }
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: PHPickerViewControllerDelegate {
        private let parent: PhotoPickerView
        init(_ parent: PhotoPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.onComplete(results)
            picker.dismiss(animated: true)
        }
    }
    
    static func convertToUIImageArray(fromResults results: [PHPickerResult], onComplete: @escaping ([UIImage]?, Error?) -> Void) {
        var images = [UIImage]()
        let dispatchGroup = DispatchGroup()
        for result in results {
            dispatchGroup.enter()
            let itemProvider = result.itemProvider
            if itemProvider.canLoadObject(ofClass: UIImage.self) {
                itemProvider.loadObject(ofClass: UIImage.self) { (imageOrNil, errorOrNil) in
                    if let error = errorOrNil {
                        onComplete(nil, error)
                    }
                    if let image = imageOrNil as? UIImage {
                        images.append(image)
                    }
                    dispatchGroup.leave()
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            onComplete(images, nil)
        }
    }
}
