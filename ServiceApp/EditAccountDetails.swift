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
    
    @State var changeName: String = ""
    @State var changeBio: String = ""
    @State var placeholderForBio = "Add Bio"
    
    init() {
        
    }
    
    var body: some View {
        NavigationView {
            VStack {
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
                VStack {
                    HStack {
                        Text("Name").font(.headline).bold()
                        Spacer(minLength: 10)
                        TextField("Name", text: $changeName)
                            .disableAutocorrection(true)
                    }
                    Text("Make sure that this is your legal name, as this will be presented to organizations when you sign up for an event and they must be able to identify you on the day of the event").foregroundColor(.gray).font(.caption)
                    Divider()
                    VStack(alignment: .leading) {
                        Text("Bio").font(.headline).bold()
                        ZStack {
                            TextEditor(text: $changeBio)
                                .disableAutocorrection(true)
                                .font(.body)
                                .opacity(self.changeBio.isEmpty ? 0.25 : 1)
                        }
                    }
                }.padding(.horizontal, 22)
                    .padding(.vertical, 20)
                
                
                    .navigationTitle("Edit profile")
                    .navigationBarTitleDisplayMode(.inline)
                    .navigationBarItems(leading:
                                            Button(action: { dismiss() })
                                        { Text("Cancel").foregroundColor(.primary) },
                                        trailing:
                                            Button(action: {
                        let oldStuff = viewModel.decodeUserInfo()!
                        if !changeName.isEmpty {
                            
                        }
                        if !changeBio.isEmpty {
                            //                            this will also need to be saved to realtime database for friends to read the info
                            viewModel.encodeUserInfo(for: UserInfoFromAuth(uid: oldStuff.uid, displayName: oldStuff.displayName, photoURL: oldStuff.photoURL, email: oldStuff.email, bio: changeBio))
                            FirebaseRealtimeDatabaseCRUD().updateUserBio(uid: oldStuff.uid, newBio: changeBio)
                        }
                        dismiss()
                        
                    })
                                        { Text("Done").bold() }
                    )
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
            .onAppear(perform: {
                changeName = (viewModel.decodeUserInfo()?.displayName ?? "")
                changeBio = (viewModel.decodeUserInfo()?.bio ?? "")
            })
            
        }
    }
}
