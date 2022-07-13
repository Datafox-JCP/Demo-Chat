//
//  ChatsListView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 07/07/22.
//

import SwiftUI

struct ChatsListView: View {

    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    
    @Binding var isChatShowing: Bool
    
    var body: some View {
        
        VStack {
                // Encabezado
                HStack {
                    Text("Chats")
                        .font(Font.pageTitle)
                    
                    Spacer()
                    
                    Button {
                        // TODO: Settings
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .tint(Color("icons-secondary"))
                    }
                }
                .padding(.top, 20)
                .padding(.horizontal)
            
            // Lista de chats
            if chatViewModel.chats.count > 0 {
                List(chatViewModel.chats) { chat in
                    Button {
                        // Fijar hat seleccionado del viewmodel
                        chatViewModel.selectedChat = chat
                        // mostrar conversación
                        isChatShowing = true
                    } label: {
                        ChatsListRow(otherParticipants: contactsViewModel.getParticipants(ids: chat.participans), chat: chat)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            } else {
                Spacer()
                
                Image("no-chats-yet")
                
                Text("No hay chats")
                    .font(Font.titleText)
                    .padding(.top, 32)
                
                Text("Mensaje...")
                    .font(Font.bodyParagraph)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
    }
}

//struct ChatsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatsListView(isChatShowing: .constant(false))
//    }
//}
