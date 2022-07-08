    //
    //  DatabaseService.swift
    //  Datafox Chat
    //
    //  Created by Juan Hernandez Pazos on 05/07/22.
    //

import Foundation
import Contacts
import Firebase
import UIKit
import FirebaseStorage
import FirebaseFirestore

class DatabaseService {
    
    func getPlaformUsers(localContacts: [CNContact], completion: @escaping ([User]) -> Void ) {
        
            // Array where we're stroing fetched platform users
        var platformUsers = [User]()
        
            // Construct an array of string phone numbers to look up
        var lookupPhoneNumbers = localContacts.map { contact in
                // Turn the contact onto a phone number as a string
            return TextHelper.samitizePhoneNumber(contact.phoneNumbers.first?.value.stringValue ?? "")
        }
        
            // Make sure that there are lookup numbers
        guard lookupPhoneNumbers.count > 0 else {
                // Callback
            completion(platformUsers)
            return
        }
            // Query the database for these phone numbers
        let db = Firestore.firestore()
        
            // Perform queries while we still have phone numbers to look up
        while !lookupPhoneNumbers.isEmpty {
                // Get the first < 10 phone numbers to look up
            let tenPhoneNumbers = Array(lookupPhoneNumbers.prefix(10))
            
                // Remove the < 10 that we're looking up
            lookupPhoneNumbers = Array(lookupPhoneNumbers.dropFirst(10))
                // Look up the first 10
            let query = db.collection("users").whereField("phone", in: tenPhoneNumbers)
            
                // Retrieve the users that are on the platform
            query.getDocuments { snapshot, error in
                    // Check for errors
                if error == nil && snapshot != nil {
                        // For each doc theat was fetched, create a user
                    for doc in snapshot!.documents {
                        if let user = try? doc.data(as: User.self) {
                                // Append to the pkatform users arrray
                            platformUsers.append(user)
                        }
                    }
                    
                        // Check if we have anym0re numbers to look up
                        // If not, we can call the completion block
                    if lookupPhoneNumbers.isEmpty {
                            // Return the users
                        completion(platformUsers)
                    }
                }
            }
        }
    }
    
    func setUserProfile(firstName: String, lastName: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        
            // Ensure that the user is logged in
        guard AuthViewModel.isUserLoggedIn() != false else {
            // User is not logged in
            return
        }
        
        // Get user0s phone number
        let userPhone = TextHelper.samitizePhoneNumber(AuthViewModel.getLoggedInUserPhone())
        
            // Get a reference to Firestore
        let db = Firestore.firestore()
        
            // Set the profile data
        let doc = db.collection("users").document(AuthViewModel.getLoggedInUserId()) // getLogged... is used to have the same Id for users profile and authenticated user
        doc.setData(["firstname": firstName,
                     "lastname": lastName,
                     "phone": userPhone])
        
            // Check if an image is passed through
        if let image = image {
            
                // Create storage reference
            let storageRef = Storage.storage().reference()
            
                // Turn our image into data
            let imageData = image.jpegData(compressionQuality: 0.8)
            
                // Check that we were able to convert it to data
            guard imageData != nil else {
                return
            }
            
                // Specify the file path and name
            let path = "images/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(path)
            
            let uploadTask = fileRef.putData(imageData!, metadata: nil) { meta, error in
                
                if error == nil && meta != nil
                {
                        // Set that image path to the profile
                    doc.setData(["photo": path], merge: true) { error in
                        if error == nil {
                                // Success, notify caller
                            completion(true)
                        }
                    }
                }
                else {
                        // Upload wasn't successful, notify caller
                    completion(false)
                }
            }
        }
    }
    
    func checkUserProfile(completion: @escaping (Bool) -> Void) {
        // Check tha the user is logged
        guard AuthViewModel.isUserLoggedIn() != false else {
            return
        }
        
        // Create Firebas ref
        let db = Firestore.firestore()
        
        db.collection("users").document(AuthViewModel.getLoggedInUserId()).getDocument { snapshot, error in
            // TODO: Keeps the user profile data
            // TODO: Look into using Result type to indicate failure
            if snapshot != nil && error == nil {
                // Notify that profile exists
                completion(snapshot!.exists)
            } else {
                completion(false)
            }
           
        }
    }
}
