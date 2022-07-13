    //
    //  RootView.swift
    //  Datafox Chat
    //
    //  Created by Juan Hernandez Pazos on 04/07/22.
    //

import SwiftUI

struct RootView: View {
    // For detecting when app state changes
    @Environment(\.scenePhase) var scenePhase
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @State var selectedTab: Tabs = .contacts
    @State var isOnboarding = !AuthViewModel.isUserLoggedIn()
    @State var isChatShowing = false
    
    var body: some View {
        ZStack {
            Color("background")
                .ignoresSafeArea()
            VStack {
                switch selectedTab {
                case .chats:
                    ChatsListView(isChatShowing: $isChatShowing)
                case .contacts:
                    ContactsListView(isChatShowing: $isChatShowing)
                }
                
                Spacer()
                
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .fullScreenCover(isPresented: $isOnboarding) {
                // On dismiss
        } content: {
                // The onboarding sequence
            OnboardingContainerView(isOnboarding: $isOnboarding)
        }
        .fullScreenCover(isPresented: $isChatShowing, onDismiss: nil) {
            // The conversation view
            ConversationView(isChatShowing: $isChatShowing)
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                print("Active")
            } else if newPhase == .inactive {
                print("Inactive")
            } else if newPhase == .background {
                chatViewModel.chatListViewCleanup()
            }
        }
        
    }
    
        // Función que lista los nombres de las fuentes disponibles, en ocasiones el nombre de la fuente no coincide con el nombre del archivo
//    init() {
//        for family in UIFont.familyNames {
//            for fontname in UIFont.fontNames(forFamilyName: family) {
//                print("--\(fontname)")
//            }
//        }
//    }
}

struct RootView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}
