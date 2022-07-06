//
//  DatabaseService.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 05/07/22.
//

import Foundation
import Contacts
import Firebase

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
                    
                    // Check if we have anynomre numbers to look up
                    // If not, we can call the completion block
                    if lookupPhoneNumbers.isEmpty {
                        // Return the users
                        completion(platformUsers)
                    }
                }
            }
        }
    }
}
