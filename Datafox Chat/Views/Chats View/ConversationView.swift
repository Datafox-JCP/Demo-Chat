//
//  ConversationView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 08/07/22.
//

import SwiftUI

struct ConversationView: View {
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    
    @Binding var isChatShowing: Bool
    
    @State var chatMessage = ""
    @State var participants = [User]()
    
    var body: some View {
        VStack(spacing: 0) {
            // Encabezado
            HStack {
                VStack(alignment: .leading) {
                    // Regresar
                    Button {
                        // Cerrar ventana de chat
                        isChatShowing = false
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color("text-header"))
                            .frame(width: 24, height: 24)
                    }
                    .padding(.bottom, 16)
                    // Name
                    if participants.count > 0 {
                        let participant = participants.first
                        
                        Text("\(participant?.firstname ?? "") \(participant?.lastname ?? "")")
                            .font(Font.chatHeading)
                            .foregroundColor(Color("text-header"))
                    }
                }
                
                Spacer()
                
                // Foto perfil
                if participants.count > 0 {
                    let participant = participants.first
                    ProfileView(user:participant!)
                }
            }
            .padding(.horizontal)
            .frame(height: 104)
            
            
            // Chat log
            // ScrollView Reader para ir al último mensaje
            ScrollViewReader { proxy in
                ScrollView {
                VStack(spacing: 24) {
                    // TODO: Se usa Array para obtener el índicE
                    ForEach(Array(chatViewModel.messages.enumerated()), id: \.element) { index, msg in
                        // TODO: Diferenciar por UserId
                        let isFromUser = msg.senderid == AuthViewModel.getLoggedInUserId()
                    
                        HStack {
                            if isFromUser {
                                // TODOD: Timestamp integrar con la función del app
                                Text(DateHelper.chatTimeStampFrom(date: msg.timestamp))
                                    .font(Font.smallText)
                                    .foregroundColor(Color("text-textfield"))
                                    .padding(.trailing)
                                
                                Spacer()
                            }
                            
                            // Mensajes
                            Text(msg.msg)
                                .font(Font.bodyParagraph)
                                .foregroundColor(isFromUser ? Color("text-button") : Color("text-primary"))
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(isFromUser ? Color("bubble-primary") :  Color("bubble-secondary"))
                                .cornerRadius(30, corners: isFromUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                            
                            if !isFromUser {
                                // Timestamp
                                Spacer()
                                
                                Text(DateHelper.chatTimeStampFrom(date: msg.timestamp))
                                    .font(Font.smallText)
                                    .foregroundColor(Color("text-textfield"))
                                    .padding(.leading)
                            }
                        }
                        .id(index) // con el index se pasa al último mensaje
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
            }
                .background(Color("background"))
                // TODO: Función para ir al último mensaje
                .onChange(of: chatViewModel.messages.count) { newCount in
                    withAnimation {
                        proxy.scrollTo(newCount - 1)
                    }
                }
            }
            
            // Barra (integrar con el input dinámico)
            ZStack {
                Color("background")
                HStack(spacing: 16) {
                    // Camera button
                    Button {
                        // TODO: Picker
                    } label: {
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .tint(Color("icons-secondary"))
                    }
                    
                    //Text field
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("date-pill"))
                            .cornerRadius(50)
                        
                        TextField("Type your message", text: $chatMessage)
                            .foregroundColor(Color("text-input"))
                            .font(Font.bodyParagraph)
                            .padding(10)
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                // ??
                            } label: {
                                Image(systemName: "face.smiling")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("text-input"))
                                }
                        }
                        .padding(.trailing, 12)
                    }
                    .frame(height: 44)
                
                    // Enviar
                    Button {
                        // Limpiar espacios en mensaje
                        chatMessage = chatMessage.trimmingCharacters(in: .whitespacesAndNewlines)
                        // Enviar mensaje
                        chatViewModel.sendMessage(msg: chatMessage)
                        // Limpiar texto
                        // TODO: Preguntar si se mantiene habilitado o sólo si hay texto
                        chatMessage = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .tint(Color("icons-primary"))
                    }
                    .disabled(chatMessage.trimmingCharacters(in: .whitespacesAndNewlines) == "")
                }
                .padding(.horizontal)
            }
            .frame(height: 76)
        }
        .onAppear {
            // Llamada a chat view model para cargar mensajes
            chatViewModel.getMessages()
            
            // Obtener otros participantes como instancias de User
            let ids = chatViewModel.getParticipantIds()
            self.participants = contactsViewModel.getParticipants(ids: ids)
        }
        .onDisappear {
            // TODO: Liberar recursos (cierra conexiones, guarda CoreData...)
            chatViewModel.conversationViewCleanup()
        }
    }
}

//struct ConversationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationView(isChatShowing: .constant(false))
//    }
//}
