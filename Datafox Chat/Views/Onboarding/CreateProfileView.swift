    //
    //  CreateProfileView.swift
    //  Datafox Chat
    //
    //  Created by Juan Hernandez Pazos on 04/07/22.
    //

import SwiftUI

struct CreateProfileView: View {
    @Binding var currentStep: OnboardingStep
    
    @State var firstName = ""
    @State var lastName = ""
    @State var selectedImage: UIImage?
    @State var isPickerShowing = false
    @State var isSourceMenuShowing = false
    @State var source: UIImagePickerController.SourceType = .photoLibrary
    @State var isSaveButtonDisable = false
    
    var body: some View {
        VStack {
            Text("Setup your Profile")
                .font(Font.titleText)
                .padding(.top, 52)
            
            Text("Just a few more details for get started")
                .font(Font.bodyParagraph)
                .padding(.top, 12)
            
            Spacer()
            
            Button {
                    // Show action sheet
                isSourceMenuShowing = true
            } label: {
                ZStack {
                    if selectedImage != nil {
                        Image(uiImage: selectedImage!)
                            .resizable()
                            .scaledToFill()
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .foregroundColor(Color.white)
                        
                        Image(systemName: "camera.fill")
                            .foregroundColor(Color("icons-input"))
                    }
                    Circle()
                        .stroke(Color("create-profile-border"), lineWidth: 2)
                }
                .frame(width: 134, height: 134)
            }
            
            Spacer()
            
            TextField("Given Name", text: $firstName)
                .textFieldStyle(CreateProfileTextfieldStyle())
            
            TextField("Last Name", text: $lastName)
                .textFieldStyle(CreateProfileTextfieldStyle())
            
            Spacer()
            
            Button {
                // Prevent double taps
                isSaveButtonDisable = true
                // Save the data
                DatabaseService().setUserProfile(firstName: firstName,
                                               lastName: lastName,
                                                 image: selectedImage) { isSuccess in
                    if isSuccess {
                        currentStep = .contacts
                    } else {
                        // TODO: Show error message to the user
                    }
                    isSaveButtonDisable = true
                }
                //currentStep = .contacts
            } label: {
                Text(isSaveButtonDisable ? "Uploading" : "Save")
            }
            .buttonStyle(OnboardingButtonStyle())
            .disabled(isSaveButtonDisable)
            .padding(.bottom, 86)
        }
        .padding(.horizontal)
        .confirmationDialog("From where?", isPresented: $isSourceMenuShowing
                            , actions: {
            Button {
                // Set the source to photo library
                // Show the image picker
                self.source = .photoLibrary
                isPickerShowing = true
            } label: {
                Text("Photo librery")
            }
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button {
                    // Set the source to camera
                    // Show the image picker
                    self.source = .camera
                    isPickerShowing = true
                } label: {
                    Text("Take photo")
                }
            }
        })
        .sheet(isPresented: $isPickerShowing) {
                // Show the image picker
            ImagePicker(selectedImage: $selectedImage, isPickerShowing: $isPickerShowing, source: self.source)
        }
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
        CreateProfileView(currentStep: .constant(.profile))
    }
}
