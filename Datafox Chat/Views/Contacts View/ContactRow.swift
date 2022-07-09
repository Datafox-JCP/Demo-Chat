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
            ProfileView(user: user)
            
            VStack(alignment: .leading, spacing: 4) {
                // Name
                Text("\(user.firstname ?? "") \(user.lastname ?? "")")
                    .font(Font.button)
                    .foregroundColor(Color("text-primary"))
                
                // Phone number
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
