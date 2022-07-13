//
//  ChatsListRow.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 12/07/22.
//

import SwiftUI

struct ChatsListRow: View {
    var otherParticipants: [User]?
    var chat: Chat
    
    var body: some View {
        
        HStack(spacing: 24) {
            // Se asume que al menos hay otro participante
            let participant = otherParticipants?.first
            
            // Imagen de perfil de los participantes
            if participant != nil {
                ProfileView(user: participant!)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Nombre
                Text(participant == nil ? "Unknown" : "\(participant!.firstname ?? "") \(participant!.lastname ?? "")")
                    .font(Font.button)
                    .foregroundColor(Color("text-primary"))
                
                // Ultimo mensahe
                Text(chat.lastmsg ?? "")
                    .font(Font.bodyParagraph)
                    .foregroundColor(Color("text-input"))
            }
            
            Spacer()
            
                // Timestamp
            Text(chat.updated == nil ? "" : DateHelper.chatTimeStampFrom(date: chat.updated!))
                    .font(Font.bodyParagraph)
                    .foregroundColor(Color("text-input"))
        }
    }
}
