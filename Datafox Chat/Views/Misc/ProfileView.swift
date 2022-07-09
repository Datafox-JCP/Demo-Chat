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
            // Check if user has a photo set
            if user.photo == nil {
                    // Display circle with first letter of name
                    ZStack {
                        Circle()
                            .foregroundColor(.white)
                        
                        Text(user.firstname?.prefix(1) ?? "")
                            .bold()
                    }
            } else {
                    // Create URL from user photo url
                    let photoUrl = URL(string: user.photo ?? "")
                    // Profile image
                    AsyncImage(url: photoUrl) { phase in
                        switch phase {
                        case .empty:
                                // Currently fetching
                            ProgressView()
                        case .success(let image):
                                // Display the fetched image
                            image
                                .resizable()
                                .clipShape(Circle())
                                .scaledToFill()
                                .clipped()
                        case .failure:
                            // Couldn't fetch profile photo
                            // Display circle with first letter of name
                            ZStack {
                                Circle()
                                    .foregroundColor(.white)
                                
                                Text(user.firstname?.prefix(1) ?? "")
                                    .bold()
                            }
                        }
                    }
                    .frame(width: 44, height: 44)
                    
            }
                // Blue border
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
