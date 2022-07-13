//
//  CacheService.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 12/07/22.
//

import Foundation
import SwiftUI

class CacheService {
    
    // Almacena los componentes de la imagen
    private static var imageCache = [String : Image]()
    
    /// Devuelve la imagen para la clave. nil es que no hay en cache
    static func getImage(forKey: String) -> Image? {
        
        return imageCache[forKey]
    }
    
    /// Almacena la imagen en cache
    static func setImage(image: Image, forKey: String) {
        imageCache[forKey] = image
    }
}
