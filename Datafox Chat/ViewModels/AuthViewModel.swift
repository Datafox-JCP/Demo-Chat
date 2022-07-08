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
        // Send the phone number to Firebase Auth
        PhoneAuthProvider.provider().verifyPhoneNumber(phone, uiDelegate: nil) { verificationId, error in
            if error == nil {
                // Got the verification id and saved to local storage
                UserDefaults.standard.set(verificationId, forKey: "authVerificationID")
                
            }
            
            DispatchQueue.main.async {
                // There was a problem sending the phone number
                // Notify the UI
                completion(error)
            }
        }
    }
    
    static func verifyCode(code: String, completion: @escaping (Error?) -> Void) {
        // Get the verification id to from local storage
        let verificationId = UserDefaults.standard.string(forKey: "authVerificationID") ?? ""
        
        // Send the code and the verification id to Firebase
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationId, verificationCode: code)
        
        // Sing in the user
        Auth.auth().signIn(with: credential) { result, error in
            DispatchQueue.main.async {
                // There was a problem sending the phone number
                // Notify the UI
                completion(error)
            }
            
            
        }
    }
}
