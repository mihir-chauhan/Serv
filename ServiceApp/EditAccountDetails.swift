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
    @Binding var toggleEditInfoSheet: Bool
    @State var selectedImage: UIImage? = nil
    @State var showPhotoPicker = false
    
    @State var changeName: String = ""
    @State var changeBio: String = ""
    @State var placeholderForBio = "Add Bio"
    @State var disableChangeName: Bool = true
    
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
                    Image(uiImage: (getImage() ?? UIImage(systemName: "photo"))!)
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(15)
                        .padding()
                }
                Button("Change Profile Picture") {
                    showPhotoPicker.toggle()
                }
                VStack {
                    HStack {
                        Text("Name").font(.headline).bold()
                        Spacer(minLength: 10)
                        TextField("Name", text: $changeName)
                            .foregroundColor(disableChangeName ? .gray : .primary)
                            .disableAutocorrection(true)
                            .disabled(disableChangeName)
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
                        
                        if !changeBio.isEmpty && selectedImage != nil {
                            saveJpg(selectedImage!)
                            FIRCloudImages().uploadPfp(uid: (viewModel.decodeUserInfo()?.uid)!, viewModel: viewModel, for: selectedImage!)
                            FirebaseRealtimeDatabaseCRUD().updateUserBio(uid: oldStuff.uid, newBio: changeBio)
                            viewModel.encodeUserInfo(for: UserInfoFromAuth(uid: oldStuff.uid, displayName: oldStuff.displayName, photoURL: oldStuff.photoURL, email: oldStuff.email, bio: changeBio, birthYear: oldStuff.birthYear))
                        }
                        else if !changeBio.isEmpty {
                            //                            this will also need to be saved to realtime database for friends to read the info
                            viewModel.encodeUserInfo(for: UserInfoFromAuth(uid: oldStuff.uid, displayName: oldStuff.displayName, photoURL: oldStuff.photoURL, email: oldStuff.email, bio: changeBio, birthYear: oldStuff.birthYear))
                            FirebaseRealtimeDatabaseCRUD().updateUserBio(uid: oldStuff.uid, newBio: changeBio)
                        }
                        else if selectedImage != nil {
//                            #error("Need to save image when first time signing in")
                            DispatchQueue.main.async {
                                saveJpg(selectedImage!)
                                FIRCloudImages().uploadPfp(uid: (viewModel.decodeUserInfo()?.uid)!, viewModel: viewModel, for: selectedImage!)
                                // note that compression happens INSIDE
                                
                                viewModel.encodeUserInfo(for: UserInfoFromAuth(uid: oldStuff.uid, displayName: oldStuff.displayName, photoURL: oldStuff.photoURL, email: oldStuff.email, bio: oldStuff.bio, birthYear: oldStuff.birthYear))
                                
                            }
                            
                            
                            
                            
                        }
                        withAnimation {
                            toggleEditInfoSheet.toggle()
                        }
                        
                    }) { Text("Done").bold() }
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
                            if let imageData = selectedImage?.jpeg(.highest) {
                                FIRCloudImages().uploadPfp(uid: (viewModel.decodeUserInfo()?.uid)!, viewModel: viewModel, for: UIImage(data: imageData) ?? UIImage())
                            }
                        }
                    }
                }
            }
            .task {
                changeName = (viewModel.decodeUserInfo()?.displayName ?? "")
                changeBio = (viewModel.decodeUserInfo()?.bio ?? "")
            }
            
        }
    }
    
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
    func saveJpg(_ image: UIImage) {
        if let jpgData = image.jpegData(compressionQuality: 0.2),
            let path = documentDirectoryPath()?.appendingPathComponent("exampleJpg.jpg") {
            try? jpgData.write(to: path)
        }
    }
    
    public func getImage() -> UIImage? {
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                            in: .userDomainMask)

        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent("exampleJpg.jpg").path)
        }
        return nil
    }
}
