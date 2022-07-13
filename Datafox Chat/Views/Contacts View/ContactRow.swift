    //
    //  ContactRow.swift
    //  Datafox Chat
    //
    //  Created by Juan Hernandez Pazos on 08/07/22.
    //

import SwiftUI

struct ContactRow: View {
    
    var user: User
    
    var body: some View {
        
        HStack(spacing: 24) {
            // Profile view carga la foto o letras
            ProfileView(user: user)
            
            VStack(alignment: .leading, spacing: 4) {
                // Nombre
                Text("\(user.firstname ?? "") \(user.lastname ?? "")")
                    .font(Font.button)
                    .foregroundColor(Color("text-primary"))
                
                // Teléfono
                Text(user.phone ?? "")
                    .font(Font.bodyParagraph)
                    .foregroundColor(Color("text-input"))
            }
            
            Spacer()
        }
    }
}

struct ContactRow_Previews: PreviewProvider {
    static var previews: some View {
        ContactRow(user: User())
    }
}
