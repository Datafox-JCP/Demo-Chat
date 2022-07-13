//
//  ChatViewModel.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 09/07/22.
//

import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
    
    @Published var chats = [Chat]()
    @Published var selectedChat: Chat?
    @Published var messages = [ChatMessage]()
    
    var databaseService = DatabaseService()
    
    init() {
        // Recupera los chats cuan es creado ChatViewModel
        getChats()
    }
    
    func getChats() {
        // Usa la base de datos
        databaseService.getAllChats { chats in
                // Carga los chats encontrados
            self.chats = chats
        }
    }
        
    func getMessages() {
        // Verifica que haya un chat seleccionado
        guard selectedChat != nil else {
            return
        }
        
        databaseService.getAllMessages(chat: selectedChat!) { msgs in
            // Devuelve los mensajes
            self.messages = msgs
        }
    }
    
    // TODO: Adaptar
    /// Buscar chat con el usuario indicado, si se encuentra definir con chart activo. Si no crear nuevo
    func getChatsFor(contact: User) {
        // Verificar que haya usuario
        guard contact.id != nil else {
            return
        }
        
        let foundChat = chats.filter { chat in
            return chat.numparticipants == 2 && chat.participans.contains(contact.id!)
        }
        
        // Encontrado chat entre el usuario y el contacto
        if !foundChat.isEmpty {
            // Definir como chat seleccionado
            self.selectedChat = foundChat.first!
            // Cargar mensajes
            getMessages()
        } else {
            // TODO: Para grupos añadir rol y variable participantes
            // No hay chat, crear nuevo
            let newChat = Chat(
                id: nil,
                numparticipants: 2,
                participans: [AuthViewModel.getLoggedInUserId(), contact.id!],
                lastmsg: nil,
                updated: nil,
                msgs: nil)
            
            // Definir como chat seleccionado
            self.selectedChat = newChat
            
            // Guardar en base de datos
            databaseService.createChat(chat: newChat) { docId in
                self.selectedChat = Chat(
                    id: docId,
                    numparticipants: 2,
                    participans: [AuthViewModel.getLoggedInUserId(), contact.id!],
                    lastmsg: nil,
                    updated: nil,
                    msgs: nil)
                
                // Añadir chat a la lista de chats
                self.chats.append(self.selectedChat!)
            }
        }
    }
    
    func sendMessage(msg: String) {
        // Verificar que haya chat seleccionado
        guard selectedChat != nil else {
            return
        }
        
        databaseService.sendMessage(msg: msg, chat: selectedChat!)
    }
    
    // TODO: Pueden servir para guardar en base de datos y codificar
    func conversationViewCleanup() {
        databaseService.detachConversationViewListeners()
    }
    
    func chatListViewCleanup() {
        databaseService.detachChatListViewListeners()
    }
    
    // MARK: - Metodos auxiliares
    // TODO: Obtiene los participantes del chat
    /// Toma un lista de ids de usuario, retira el usuario de la lista de ids y devuelve los restantes
    func getParticipantIds() -> [String] {
        // Verificar que haya chat seleccionado
        guard selectedChat != nil else {
            return [String]()
        }
        
        // Filtrar los ids de usuarios
        let ids = selectedChat!.participans.filter { id in
            id != AuthViewModel.getLoggedInUserId()
        }
        
        return ids
    }
}
