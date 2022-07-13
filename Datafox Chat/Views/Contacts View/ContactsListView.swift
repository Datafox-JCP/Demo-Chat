//
//  ContactsListView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 07/07/22.
//

import SwiftUI

struct ContactsListView: View {
    
    @EnvironmentObject var contactsViewModel: ContactsViewModel
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @Binding var isChatShowing: Bool
    
    @State var filterText = ""
    
    var body: some View {
        
        VStack {
            
            // Encabezado
            HStack {
                Text("Contacts")
                    .font(Font.pageTitle)
                
                Spacer()
                
                Button {
                    // TODO: Settings
                } label: {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .tint(Color("icons-secondary"))
                }
            }
            .padding(.top, 20)
            
            // Búsqueda
            ZStack {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(20)
                TextField("Search contact or number", text: $filterText)
                    .font(Font.tabBar)
                    .foregroundColor(Color("text-textfield"))
                    .padding()
            }
            .frame(height: 46)
            .onChange(of: filterText) { _ in
                // Filtrar los resultados
                // TODO: funciona, considerar en vez de Navigation
                contactsViewModel.filterContacts(filterBy: filterText.lowercased().trimmingCharacters(in: .whitespacesAndNewlines))
            }
            
            if contactsViewModel.filteredUsers.count > 0 {
                // Lista
                List(contactsViewModel.filteredUsers) { user in
                    
                    Button {
                        // Buscar la conversación existente con el contacto
                        chatViewModel.getChatsFor(contact: user)
                        
                        // Mostrar conversation view
                        isChatShowing = true
                    } label: {
                        // Mostrar rows
                        ContactRow(user: user)
                    }
                    .buttonStyle(.plain)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
                .padding(.top, 12)
            } else {
                Spacer()
                
                Image("no-contacts-yet")
                
                Text("Sin contacto")
                    .font(Font.titleText)
                    .padding(.top, 32)
                
                Text("Mensaje...")
                    .font(Font.bodyParagraph)
                    .padding(.top, 8)
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .onAppear {
            // Contactos locales
            contactsViewModel.getLocalContacts()
        }
    }
}

struct ContactsListView_Previews: PreviewProvider {
    static var previews: some View {
        ContactsListView(isChatShowing: .constant(false))
    }
}
