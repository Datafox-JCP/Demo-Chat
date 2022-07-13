//
//  User.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 05/07/22.
//

import Foundation
import FirebaseFirestoreSwift

// Sólo muestra

struct User: Codable, Identifiable {
    @DocumentID var id: String?
    var firstname: String?
    var lastname: String?
    var phone: String?
    var photo: String?
}
