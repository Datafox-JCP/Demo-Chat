//
//  TextHelper.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 05/07/22.
//

import Foundation

class TextHelper {
    
    // USando para dejar sólo números de un número de teléfono
    static func samitizePhoneNumber(_ phone: String) -> String {
        
        return phone
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: " ", with: "")
    }
    
    // Limitar el número de carácteres
    // https://stackoverflow.com/questions/56476007/swiftui-textfield-max-length
    static func limitText(_ stringvar: inout String, _ limit: Int) {
        if stringvar.count > limit {
            stringvar = String(stringvar.prefix(limit))
        }
    }
    
    // Formatear números en base a patrón
    // https://stackoverflow.com/questions/32364055/formatting-phone-number-in-swift
    static func applyPatternOnNumbers(_ stringvar: inout String, pattern: String, replacementCharacter: Character) {
        var pureNumber = stringvar.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else {
                stringvar = pureNumber
                return
            }
            let stringIndex = String.Index(utf16Offset: index, in: pattern)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacementCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        stringvar = pureNumber
        
        // Limitar caracteres a 17 para que sea +# (###) ###-####
        if stringvar.count > 17 {
            stringvar = String(stringvar.prefix(17))
        }
    }
}
