//
//  DateHelper.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 11/07/22.
//

import Foundation

class DateHelper {
    static func chatTimeStampFrom(date: Date?) -> String {
        
        guard date != nil else {
            return ""
        }
        
        let df = DateFormatter()
        df.dateFormat = "h:mm a"
        
        return df.string(from: date!)
    }
}
