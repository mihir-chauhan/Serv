//
//  EditAccountDetails.swift
//  ServiceApp
//
//  Created by Kelvin J on 4/24/22.
//

import SwiftUI

struct EditAccountDetails: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State var selectedImage: UIImage? = nil
    @State var showPhotoPicker = false
    var body: some View {
        if let image = selectedImage {
            Image(uiImage: image)
                .resizable()
                .frame(width: 150, height: 150)
                .aspectRatio(contentMode: .fit)
                .cornerRadius(15)
                .padding()
        } else {
            AsyncImage(url: viewModel.decodeUserInfo()?.photoURL ?? UserInfoFromAuth().photoURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image.resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .padding()
                    
                case .failure:
                    Image(systemName: "photo")
                @unknown default:
                    ProgressView()
                }
            }
        }
        Button("Change Profile Picture") {
            showPhotoPicker.toggle()
        }
        
        Button("Submit") {
            dismiss()
        }
        .fullScreenCover(isPresented: $showPhotoPicker) {
            PhotoPicker() { results in
                PhotoPicker.convertToUIImageArray(fromResults: results) { imageOrNil, errorOrNil in
                    if let error = errorOrNil {
                        print(error)
                    }
                    if let images = imageOrNil {
                        selectedImage = images.first
                        if let imageData = selectedImage?.jpeg(.lowest) {
                            FIRCloudImages().uploadPfp(uid: (viewModel.decodeUserInfo()?.uid)!, viewModel: viewModel, for: imageData)
                        }
                    }
                }
            }
        }
    }
}

struct EditAccountDetails_Previews: PreviewProvider {
    static var previews: some View {
        EditAccountDetails()
    }
}
