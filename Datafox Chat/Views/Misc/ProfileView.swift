//
//  ProfileView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 08/07/22.
//

import SwiftUI

struct ProfileView: View {
    
    var user: User
    var body: some View {
        ZStack {
            // Vetificar por foto
            if user.photo == nil {
                    // Circulo y letras
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                        
                        Text(user.firstname?.prefix(2) ?? "")
                            .bold()
                    }
            } else {
                    // URL de foto
                    let photoUrl = URL(string: user.photo ?? "")
                    // Foto perfil
                    // TODO: Verificar si es en línea o se guarda
                    AsyncImage(url: photoUrl) { phase in
                        switch phase {
                        case .empty:
                                // Carga
                            ProgressView()
                        case .success(let image):
                                // Mostrar
                            image
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .clipped()
                        case .failure:
                            // Error
                            // Cargar letras
                            ZStack {
                                Circle()
                                    .foregroundColor(.white)
                                
                                Text(user.firstname?.prefix(2) ?? "")
                                    .bold()
                            }
                        }
                    }
                    .frame(width: 44, height: 44)
                    
            }
                // Border
            Circle()
                .stroke(Color("create-profile-border"), lineWidth: 2)
        }
        .frame(width: 44, height: 44)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(user: User())
    }
}
