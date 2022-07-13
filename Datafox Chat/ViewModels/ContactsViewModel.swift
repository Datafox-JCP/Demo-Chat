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
        
        // Ejecutar método de forma asincrona - no bloquear la UI
        DispatchQueue.init(label: "getcontacts").async {
            do {
                // Permiso
                let store = CNContactStore()
                
                // Claves a obtener
                let keys = [CNContactPhoneNumbersKey,
                            CNContactGivenNameKey,
                            CNContactFamilyNameKey] as [CNKeyDescriptor]
                
                // Crear Fetch request
                let fetchRequest = CNContactFetchRequest(keysToFetch: keys)
                
                // Obtener contactos del dispositvo
                try store.enumerateContacts(with: fetchRequest, usingBlock: { contact, success in
                    //  Añadir el contacto
                    self.localContacts.append(contact)
                })
                
                // Cuáles contactos son usuarios del app
                DatabaseService().getPlaformUsers(localContacts: self.localContacts) { platformUsers in
                
                    // Atualizar la UI
                    DispatchQueue.main.async {
                        // Obtener los usuarios
                        self.users = platformUsers
                        
                        // Defnir listra filtrada
                        self.filterContacts(filterBy: self.filterText)
                    }
                }
            }
            catch {
                // Manejar error
            }
        }
    }
    
    // TODO: Función de búsqueda de contactos
    func filterContacts(filterBy: String) {
        // Almacenar parámetro en propiedad
        self.filterText = filterBy
        
        // Si el filtro de texto está vacio, mostrar todos los usuarios
        if filterText == "" {
            self.filteredUsers = users
            return
        }
        
        // Ejecuta el filtro
        self.filteredUsers = users.filter( { user in
            // Criterio para los usuarios en el filtro
            user.firstname?.lowercased().contains(filterText) ?? false ||
            user.lastname?.lowercased().contains(filterText) ?? false ||
            user.phone?.lowercased().contains(filterText) ?? false
        })
    }
    
    /// Dada una lista de ids devolver una lusta de objetos user con los mismos ids
    func getParticipants(ids: [String]) -> [User] {
        
        // TODO: Filtrar los usuarios para mostrar sólo los participantes (Esto para los chats, resuelve el tema de Grupos
        let foundUsers = users.filter { user in
            if user.id == nil {
                return false
            } else {
                return ids.contains(user.id!)
            }
        }
        
        return foundUsers
    }
}
