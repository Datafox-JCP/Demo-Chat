//
//  Chat.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 08/07/22.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Codable, Identifiable {
    @DocumentID var id: String?
    var numparticipants: Int
    var participans: [String]
    var lastmsg: String?
    @ServerTimestamp var updated: Date?
    var msgs: [ChatMessage]?
}

struct ChatMessage: Codable, Identifiable, Hashable {
    @DocumentID var id: String?
    var imageurl: String?
    var msg: String
    @ServerTimestamp var timestamp: Date?
    var senderid: String
}
