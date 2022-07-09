//
//  ConversationView.swift
//  Datafox Chat
//
//  Created by Juan Hernandez Pazos on 08/07/22.
//

import SwiftUI

struct ConversationView: View {
    
    @EnvironmentObject var chatViewModel: ChatViewModel
    
    @Binding var isChatShowing: Bool
    
    @State var chatMessage = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Chat header
            HStack {
                VStack(alignment: .leading) {
                    // Back arrow
                    Button {
                        // Dismiss chat window
                        isChatShowing = false
                    } label: {
                        Image(systemName: "arrow.backward")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(Color("text-header"))
                            .frame(width: 24, height: 24)
                    }
                    
                    // Name
                    Text("JCP")
                        .font(Font.chatHeading)
                        .foregroundColor(Color("text-header"))
                        
                }
                
                Spacer()
                
                // Profile image
                ProfileView(user: User())
            }
            .padding(.horizontal)
            .frame(height: 104)
            
            
            // Chart log
            ScrollView {
                VStack(spacing: 24) {
                    
                    ForEach(chatViewModel.messages) { msg in
                        let isFromUser = msg.senderid == AuthViewModel.getLoggedInUserId()
                        
                        // Dynamic message
                        HStack {
                            
                            if isFromUser {
                                // Timestamp
                                Text("9:41")
                                    .font(Font.smallText)
                                    .foregroundColor(Color("text-textfield"))
                                    .padding(.trailing)
                                
                                Spacer()
                            }
                            
                            // Message
                            Text(msg.msg)
                                .font(Font.bodyParagraph)
                                .foregroundColor(isFromUser ? Color("text-button") : Color("text-primary"))
                                .padding(.vertical, 16)
                                .padding(.horizontal, 24)
                                .background(isFromUser ? Color("bubble-primary") :  Color("bubble-secondary"))
                                .cornerRadius(30, corners: isFromUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
                            
                            if !isFromUser {
                                // Timestamp
                                
                                Spacer()
                                
                                Text("9:41")
                                    .font(Font.smallText)
                                    .foregroundColor(Color("text-textfield"))
                                    .padding(.trailing)
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)
            }
            .background(Color("background"))
            .ignoresSafeArea()
            
            // Chat message bar
            ZStack {
                Color("background")
                HStack(spacing: 16) {
                    // Camera button
                    Button {
                        //
                    } label: {
                        Image(systemName: "camera")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .tint(Color("icons-secondary"))
                    }
                    
                    //Text field
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color("date-pill"))
                            .cornerRadius(50)
                        
                        TextField("Type your message", text: $chatMessage)
                            .foregroundColor(Color("text-input"))
                            .font(Font.bodyParagraph)
                            .padding(10)
                        
                        HStack {
                            Spacer()
                            
                            Button {
                                //
                            } label: {
                                Image(systemName: "face.smiling")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color("text-input"))
                                }
                        }
                        .padding(.trailing, 12)
                    }
                    .frame(height: 44)
                
                    // Send button
                    Button {
                        // Send message
                        chatViewModel.sendMessage(msg: chatMessage)
                        // Clear textbox
                        chatMessage = ""
                    } label: {
                        Image(systemName: "paperplane.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)
                            .tint(Color("icons-primary"))
                    }

                }
                .padding(.horizontal)
            }
            .frame(height: 76)
        }
        .onAppear {
            // Call chat view model to retrieve all chat messages
            chatViewModel.getMessages()
        }
    }
}

//struct ConversationView_Previews: PreviewProvider {
//    static var previews: some View {
//        ConversationView(isChatShowing: .constant(false))
//    }
//}
