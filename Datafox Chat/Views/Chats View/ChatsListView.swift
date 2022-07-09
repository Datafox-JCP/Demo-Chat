//
//  ChatsListView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 07/07/22.
//

import SwiftUI

struct ChatsListView: View {
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @Binding var isChatShowing: Bool
    
    var body: some View {
        
        if chatViewModel.chats.count > 0 {
            List(chatViewModel.chats) { chat in
                Button {
                    // Set selected chat for the chatviewmodel
                    chatViewModel.selectedChat = chat
                    // display conversation view
                    isChatShowing = true
                } label: {
                    Text(chat.id ?? "Empty chat id")
                }
            }
        } else {
            Text("No chats")
        }
    }
}

struct ChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView(isChatShowing: .constant(false))
    }
}
