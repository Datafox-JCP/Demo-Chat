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
    
    func sendMessage(msg: String) {
        // Check taht we have a selected chat
        guard selectedChat != nil else {
            return
        }
        
        databaseService.sendMessage(msg: msg, chat: selectedChat!)
    }
}
