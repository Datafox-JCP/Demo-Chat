//
//  RootView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 04/07/22.
//

import SwiftUI

struct RootView: View {
    @State var selectedTab: Tabs = .contacts
    @State var isOnboarding = !AuthViewModel.isUserLoggedIn()
    
    var body: some View {
        VStack {
            Text("Fuente personalizada")
                .padding()
                .font(Font.chatHeading)
            
            Spacer()
            
            CustomTabBar(selectedTab: $selectedTab)
        }
        .fullScreenCover(isPresented: $isOnboarding) {
            // On dismiss
        } content: {
            // The onboarding sequence
            OnboardingContainerView(isOnboarding: $isOnboarding)
        }
        
    }
    
    // Función que lista los nombres de las fuentes disponibles, en ocasiones el nombre de la fuente no coincide con el nombre del archivo
    init() {
        for family in UIFont.familyNames {
            for fontname in UIFont.fontNames(forFamilyName: family) {
                print("--\(fontname)")
            }
        }
    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
