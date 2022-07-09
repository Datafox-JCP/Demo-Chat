//
//  ContactsViewModel.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 05/07/22.
//

import Foundation
import Contacts

class ContactsViewModel: ObservableObject {
    
    private var users = [User]()
    
    private var filterText = ""
    @Published var filteredUsers = [User]()
    
    private var localContacts = [CNContact]()
    
    func getLocalContacts() {
        
        // Perform the contact store method asynchronously for not block the main UIT
        DispatchQueue.init(label: "getcontacts").async {
            do {
                // Ask for permission
                let store = CNContactStore()
                
                // List of keys we want to get
                let keys = [CNContactPhoneNumbersKey,
                            CNContactGivenNameKey,
                            CNContactFamilyNameKey] as [CNKeyDescriptor]
                
                // Create a Fetch request
                let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                
                // Get the contacts on the user's phone
                try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, success in
                    // Do something with the contact
                    self.localContacts.append(contact)
                })
                
                // See which local contaxts are actually users of this app
                DatabaseService().getPlaformUsers(localContacts: self.localContacts) { platformUsers in
                
                    // Update the UI in the main thread
                    DispatchQueue.main.async {
                        // Get the fethed users to the published users property
                        self.users = platformUsers
                        
                        // Set the filtered list
                        self.filterContacts(filterBy: self.filterText)
                    }
                }
            }
            catch {
                // Handle error
            }
        }
    }
    
    func filterContacts(filterBy: String) {
        // Store parameter into property
        self.filterText = filterBy
        
        // If filter text is empty, then reveal all users
        if filterText == "" {
            self.filteredUsers = users
            return
        }
        
        // Run the user list through the filter term to get the list of filtered isers
        self.filteredUsers = users.filter( { user in
            // Criteria for including this user into filtered users list
            user.firstname?.lowercased().contains(filterText) ?? false ||
            user.lastname?.lowercased().contains(filterText) ?? false ||
            user.phone?.lowercased().contains(filterText) ?? false
        })
    }
}
