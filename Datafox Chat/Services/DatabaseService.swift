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
    
    var chatListViewListeners = [ListenerRegistration]()
    var conversationViewListeners = [ListenerRegistration]()
    
    func getPlaformUsers(localContacts: [CNContact], completion: @escaping ([User]) -> Void ) {
        
            // Array para almacenar los usuarios de la plataforma
        var platformUsers = [User]()
        
            // Construir array de los teléfonos
        var lookupPhoneNumbers = localContacts.map { contact in
                // Convertir el contacto en telefono
            return TextHelper.samitizePhoneNumber(contact.phoneNumbers.first?.value.stringValue ?? "")
        }
        
            // Asegurar que haya números a buscar
        guard lookupPhoneNumbers.count > 0 else {
                // Callback
            completion(platformUsers)
            return
        }
            // Consultar en la base de datos
        let db = Firestore.firestore()
        
            // Ejecutar la consulta mientrás haya números a consultar
        while !lookupPhoneNumbers.isEmpty {
                // Obtener los primeros 10
            let tenPhoneNumbers = Array(lookupPhoneNumbers.prefix(10))
            
                // Remover los 10 que se buscaron
            lookupPhoneNumbers = Array(lookupPhoneNumbers.dropFirst(10))
                // Comparar
            let query = db.collection("users").whereField("phone", in: tenPhoneNumbers)
            
                // Recuperar los usuarios de la plataforma
            query.getDocuments { snapshot, error in
                    // Check for errors
                if error == nil && snapshot != nil {
                        // Para cada usuario crear un documento
                    for doc in snapshot!.documents {
                        if let user = try? doc.data(as: User.self) {
                                // Añadir al array de la plataforma
                            platformUsers.append(user)
                        }
                    }
                    
                        // Verificar si hay más números a buscar
                        // Cerrar el bloque si no hay más
                    if lookupPhoneNumbers.isEmpty {
                            // Devolver usuarios
                        completion(platformUsers)
                    }
                }
            }
        }
    }
    
    // TODO: Puede servir en especial el código de la foto de perfil
    func setUserProfile(firstName: String, lastName: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        
            // Verificar que el usuario se haya logeado
        guard AuthViewModel.isUserLoggedIn() != false else {
            return
        }
        
            // Obtener número de teléfono
        let userPhone = TextHelper.samitizePhoneNumber(AuthViewModel.getLoggedInUserPhone())
        
            // Referencia a Firestore
        let db = Firestore.firestore()
        
            // Datos de perfil
        let doc = db.collection("users").document(AuthViewModel.getLoggedInUserId())
        doc.setData(["firstname": firstName,
                     "lastname": lastName,
                     "phone": userPhone])
        
            // Verificar si hay imagen
        if let image = image {
                // Referencia
            let storageRef = Storage.storage().reference()
                // Convertir la imagen
            let imageData = image.jpegData(compressionQuality: 0.8)
            
                // Verificar la conversión
            guard imageData != nil else {
                return
            }
            
                // Ruta y nombre de archivo
            let path = "images/\(UUID().uuidString).jpg"
            let fileRef = storageRef.child(path)
            
            let uploadTask = fileRef.putData(imageData!, metadata: nil) { meta, error in
                
                if error == nil && meta != nil
                {
                        // URL de la imagen
                    fileRef.downloadURL { url, error in
                            // Checar errores
                        if url != nil && error == nil {
                                // Asignar la ruta al perfil
                            doc.setData(["photo": url!.absoluteString], merge: true) { error in
                                if error == nil {
                                        // Notificar
                                    completion(true)
                                }
                            }
                        } else {
                                // Error
                            completion(false)
                        }
                    }
                } else {
                        // Error
                    completion(false)
                }
            }
        } else {
                // Sin imagen
            completion(true)
        }
    }
    
    func checkUserProfile(completion: @escaping (Bool) -> Void) {
            // Verificar usuario logeado
        guard AuthViewModel.isUserLoggedIn() != false else {
            return
        }
        
            // Crear referencia
        let db = Firestore.firestore()
        
        db.collection("users").document(AuthViewModel.getLoggedInUserId()).getDocument { snapshot, error in
            if snapshot != nil && error == nil {
                    // Notificar que hay perfil
                completion(snapshot!.exists)
            } else {
                    // Error
                completion(false)
            }
            
        }
    }
    
    // MARK: - Métodos chat
    
    /// Este método devuelve todos los registros del chat en los ucales el usuario logeado sea participante
    // TODO: Puede servir la lógica sobre los chats en los que participa
    func getAllChats(completion: @escaping ([Chat]) -> Void) {
        
        // Referencia
        let db = Firestore.firestore()
        
        // Ejecutar búsuqeda para encontrar los chats en las que el usuario sea participante
        let chatsQuery = db.collection("chats")
            .whereField("participants",
                        arrayContains: AuthViewModel.getLoggedInUserId())
        
        let listener = chatsQuery.addSnapshotListener { snapshot, error in
            
            if snapshot != nil && error == nil {
                
                var chats = [Chat]()
                
                    // Loop
                for doc in snapshot!.documents {
                    
                        // Parse los datos en la struct Chat
                    let chat = try? doc.data(as: Chat.self)
                    
                        // Añadir al array
                    if let chat = chat {
                        chats.append(chat)
                    }
                }
                
                    // Devolver los datos
                completion(chats)
            }
            else {
                print("Error in database retrieval")
            }
        }
        
        // Registrar el usuario para ceerrarlo
        chatListViewListeners.append(listener)
    }
    
    /// Este método devuelve todos los mesajes de un chat
    func getAllMessages(chat: Chat, completion: @escaping ([ChatMessage]) -> Void) {
        // Check that the is is no nil
        guard chat.id != nil else {
            // Error
            completion([ChatMessage]())
            return
        }
        
        // Refeencia
        let db = Firestore.firestore()
        // Create the query
        let msgsQuery = db.collection("chats")
            .document(chat.id!)
            .collection("msgs")
            .order(by: "timestamp")
        
        // Ejecutar la consulta
        let listener = msgsQuery.addSnapshotListener { snapshot, error in
            if snapshot != nil && error == nil {
                var messages = [ChatMessage]()
                // Loop en los registros para crear las instancias de ChatMessage
                for doc in snapshot!.documents {
                    // Parse los datos en el struct Chat
                    let msg = try? doc.data(as: ChatMessage.self)
                    // Añadir al array
                    if let msg = msg {
                        messages.append(msg)
                    }
                }
                
                // Devolver los datos
                completion(messages)
            } else {
                print("Error in database retrieval")
            }
        }
        
            // Registrar el listener para cerrarlo
            conversationViewListeners.append(listener)
    }
    
    /// Enviar mensaje
    func sendMessage(msg: String, chat: Chat) {
        // Verificar si el chat es válido
        guard chat.id != nil else {
            return
        }

        
        // Referencia
        let db = Firestore.firestore()
        
        // Add msg document
        db.collection("chats")
            .document(chat.id!)
            .collection("msgs")
            .addDocument(data: ["imageurl": "",
                                "msg": msg,
                                "senderid": AuthViewModel.getLoggedInUserId(),
                                "timestamp": Date()])
        
        // Actualizar el documento apra reflejar el mensaje enviado
        db.collection("chats")
            .document(chat.id!)
            .setData(["updated": Date(),
                     "lastmsg": msg],
                     merge: true)
    }
    
    // Método para crear un nuevo chat y obtener su id
    func createChat(chat: Chat, completion: @escaping (String) -> Void) {
        // Referencia
        let db = Firestore.firestore()
        // Crear un docuemnto
        let doc = db.collection("chats").document()
        
        // Datos para el documento
        try? doc.setData(from: chat, completion: { error in
            // Pasar el id
            completion(doc.documentID)
        })
    }
    
    // Remover los listeners
    func detachChatListViewListeners() {
        for listener in chatListViewListeners {
            listener.remove()
        }
    }
    
    func detachConversationViewListeners() {
        for listener in conversationViewListeners {
            listener.remove()
        }
    }
}
