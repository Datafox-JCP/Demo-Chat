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
            // Assume at least 1 other participant in the chat
            let participant = otherParticipants?.first
            
            // Profile image of participants
            if participant != nil {
                ProfileView(user: participant!)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text(participant == nil ? "Unknown" : "\(participant!.firstname ?? "") \(participant!.lastname ?? "")")
                    .font(Font.button)
                    .foregroundColor(Color("text-primary"))
                
                // Last message
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
