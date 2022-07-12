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
        // Retrieved chats when ChatViewModel is created
        getChats()
    }
    
    func getChats() {
        // Use the database service to retrieve the chats
        databaseService.getAllChats { chats in
                // Set the retrieved data to the chats property
            self.chats = chats
        }
    }
        
    func getMessages() {
        // Check that there's a selected chat
        guard selectedChat != nil else {
            return
        }
        
        databaseService.getAllMessages(chat: selectedChat!) { msgs in
            // Set returned messages to property
            self.messages = msgs
        }
    }
    
    /// Search for chat with passed in user, if found, set as selected chat. If not found, create a new chat
    func getChatsFor(contact: User) {
        // Check the user
        guard contact.id != nil else {
            return
        }
        
        let foundChat = chats.filter { chat in
            return chat.numparticipants == 2 && chat.participans.contains(contact.id!)
        }
        
        // Found a chat between the user and the contact
        if !foundChat.isEmpty {
            // Set as selected chat
            self.selectedChat = foundChat.first!
            // Fetch the messages
            getMessages()
        } else {
            // No chat was found create a new one
            let newChat = Chat(
                id: nil,
                numparticipants: 2,
                participans: [AuthViewModel.getLoggedInUserId(), contact.id!],
                lastmsg: nil,
                updated: nil,
                msgs: nil)
            
            // Set as selected chat
            self.selectedChat = newChat
            
            // Save new chat to the database
            databaseService.createChat(chat: newChat) { docId in
                self.selectedChat = Chat(
                    id: docId,
                    numparticipants: 2,
                    participans: [AuthViewModel.getLoggedInUserId(), contact.id!],
                    lastmsg: nil,
                    updated: nil,
                    msgs: nil)
                
                // Add chat to the chat list
                self.chats.append(self.selectedChat!)
            }
        }
    }
    
    func sendMessage(msg: String) {
        // Check taht we have a selected chat
        guard selectedChat != nil else {
            return
        }
        
        databaseService.sendMessage(msg: msg, chat: selectedChat!)
    }
    
    // MARK: - Helper methods
    /// Takes in a list of user ids, removes the user from that list and list and returns the remaining ids
    func getParticipantIds() -> [String] {
        // Check that we have a selected chat
        guard selectedChat != nil else {
            return [String]()
        }
        
        // Filter out the user's id
        let ids = selectedChat!.participans.filter { id in
            id != AuthViewModel.getLoggedInUserId()
        }
        
        return ids
    }
}
