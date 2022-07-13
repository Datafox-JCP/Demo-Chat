//
//  AuthViewModel.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 04/07/22.
//

import Foundation
import FirebaseAuth

class AuthViewModel {
    
    static func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
    
    static func getLoggedInUserId() -> String {
        return Auth.auth().currentUser?.uid ?? ""
    }
    
    static func getLoggedInUserPhone() -> String {
        return Auth.auth().currentUser?.phoneNumber ?? ""
    }
    
    static func logout() {
        try? Auth.auth().signOut()
    }
    
    static func sendPhoneNumber(phone: String, completion: @escaping (Error?) -> Void) {
        //Enviar número de telefono para autorización
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, error in
            if error == nil {
                // Guarda el id de verificación
                UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                
            }
            
            DispatchQueue.main.async {
                // Error
                // Notificar a UI
                completion(error)
            }
        }
    }
    
    static func verifyCode(code: String, completion: @escaping (Error?) -> Void) {
        // Obtener el id de verificación del local
        let verificationId = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        
        // Enviar código a Firebase
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        
        // Logear usuario
        Auth.auth().signIn(with: credential) { result, error in
            DispatchQueue.main.async {
                // Error
                // Notificar a la UI
                completion(error)
            }
            
            
        }
    }
}
