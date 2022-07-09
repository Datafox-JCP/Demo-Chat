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
        
            // Get users phone number
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
                        // Get full url to image
                    fileRef.downloadURL { url, error in
                            // Check for errors
                        if url != nil && error == nil {
                                // Set that image path to the profile
                            doc.setData(["photo": url?.absoluteString], merge: true) { error in
                                if error == nil {
                                        // Success, notify caller
                                    completion(true)
                                }
                            }
                        } else {
                                // Wasn't successfull in getting download url for photo
                            completion(false)
                        }
                    }
                } else {
                        // Upload wasn't successful, notify caller
                    completion(false)
                }
            }
        } else {
                // No image was set
            completion(true)
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
    
    // MARK: - Chat methods
    
    /// This method returns all chat documents where the logged in user is a participant
    func getAllChats(completion: @escaping ([Chat]) -> Void) {
        
            // Get a reference to the database
        let db = Firestore.firestore()
        
            // Perform a query against the chat collection for any chats where the user is a participant
        let chatsQuery = db.collection("chats")
            .whereField("participants",
                        arrayContains: AuthViewModel.getLoggedInUserId())
        
        chatsQuery.getDocuments { snapshot, error in
            
            if snapshot != nil && error == nil {
                
                var chats = [Chat]()
                
                    // Loop through all the returned chat docs
                for doc in snapshot!.documents {
                    
                        // Parse the data into Chat structs
                    let chat = try? doc.data(as: Chat.self)
                    
                        // Add the chat into the array
                    if let chat = chat {
                        chats.append(chat)
                    }
                }
                
                    // Return the data
                completion(chats)
            }
            else {
                print("Error in database retrieval")
            }
        }
    }
    
    /// This method returns all messages for a given chats
    func getAllMessages(chat: Chat, completion: @escaping ([ChatMessage]) -> Void) {
            // Check that the is is no nil
        guard chat.id != nil else {
                // Can't fetch data
            completion([ChatMessage]())
            return
        }
        
            // Get a reference to the database
        let db = Firestore.firestore()
            // Create the query
        let msgsQuery = db.collection("chats")
            .document(chat.id!)
            .collection("msgs")
            .order(by: "timestamp")
            // Perform the query
        msgsQuery.getDocuments { snapshot, error in
            if snapshot != nil && error == nil {
                var messages = [ChatMessage]()
                    // Loop through the msg documents and create ChatMessage instances
                for doc in snapshot!.documents {
                        // Parse the data into Chat structs
                    let msg = try? doc.data(as: ChatMessage.self)
                        // Add the chat into the array
                    if let msg = msg {
                        messages.append(msg)
                    }
                }
                
                    // Return the data
                completion(messages)
            } else {
                print("Error in databsae retrieval")
            }
        }
    }
    
    /// Send a message to the database
    func sendMessage(msg: String, chat: Chat) {
        // Check that it's a valid chat
        guard chat.id != nil else {
            return
        }
        
        // Get a reference to dabase
        let db = Firestore.firestore()
        
        // Add msg document
        db.collection("chats")
            .document(chat.id!)
            .collection("msgs")
            .addDocument(data: ["imageurl": "",
                                "msg": msg,
                                "senderid": AuthViewModel.getLoggedInUserId(),
                                "timestamp": Date()])
    }
}
