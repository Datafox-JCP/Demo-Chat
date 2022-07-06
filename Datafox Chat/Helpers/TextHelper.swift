//
//  TextHelper.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 05/07/22.
//

import Foundation

class TextHelper {
    
    static func samitizePhoneNumber(_ phone: String) -> String {
        
        return phone
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
}
